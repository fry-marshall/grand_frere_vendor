import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../menu/domain/entities/vendor_item.dart';
import '../../domain/repositories/counter_repository.dart';
import 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit(this._repo) : super(const CounterScanning());

  final CounterRepository _repo;

  Future<void> lookup(String cardCode, List<VendorItem> menu) async {
    emit(const CounterLoadingPreview());
    final result = await _repo.preview(cardCode);
    result.fold(
      (f) => emit(CounterScanError(_mapFailure(f.message))),
      (preview) =>
          emit(CounterReady(cardCode: cardCode, preview: preview, menu: menu)),
    );
  }

  void increment(String itemId) => _changeQuantity(itemId, 1);

  void decrement(String itemId) => _changeQuantity(itemId, -1);

  void _changeQuantity(String itemId, int delta) {
    final current = state;
    if (current is! CounterReady || current.isSubmitting) return;
    final quantities = Map<String, int>.of(current.quantities);
    final next = (quantities[itemId] ?? 0) + delta;
    if (next <= 0) {
      quantities.remove(itemId);
    } else {
      quantities[itemId] = next;
    }
    emit(current.copyWith(quantities: quantities));
  }

  Future<void> pay(String pin) async {
    final current = state;
    if (current is! CounterReady || !current.canPay) return;
    emit(current.copyWith(isSubmitting: true));

    final result = await _repo.sell(
      cardCode: current.cardCode,
      lines: current.lines,
      pin: pin,
    );
    result.fold(
      (f) => emit(
        CounterSaleError(message: _mapFailure(f.message), previous: current),
      ),
      (sale) => emit(
        CounterSold(
          preview: current.preview,
          orderId: sale.orderId,
          total: sale.total,
        ),
      ),
    );
  }

  /// Back to the cart after a rejected sale's error has been shown.
  void dismissError() {
    final current = state;
    if (current is CounterSaleError) emit(current.previous);
  }

  void restart() => emit(const CounterScanning());

  String _mapFailure(String message) => switch (message) {
    'Card not found' => 'Carte inconnue.',
    'Card is not active' => "Cette carte n'est pas active.",
    'Student not found' => "Cette carte n'est attribuée à aucun élève.",
    "This vendor does not belong to the student's school" =>
      "Cet élève n'est pas inscrit dans ton école.",
    'Vendor account must be approved before accessing orders' =>
      "Ton compte vendeur n'est pas encore actif.",
    'Insufficient wallet balance' => "Solde de l'élève insuffisant.",
    'Daily spending limit exceeded' =>
      "Le plafond journalier de l'élève est atteint.",
    'One or more items are invalid or unavailable' =>
      "Un des articles n'est plus disponible.",
    'Invalid PIN' => 'Code PIN incorrect.',
    'Card is blocked after 3 failed PIN attempts' =>
      'Carte bloquée (3 tentatives de PIN échouées).',
    'Card PIN is not set' => "Le code PIN de cette carte n'est pas configuré.",
    _ => message,
  };
}
