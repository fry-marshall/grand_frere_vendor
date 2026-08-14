import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/cashin_repository.dart';
import 'cashin_state.dart';

class CashinCubit extends Cubit<CashinState> {
  CashinCubit(this._repo) : super(const CashinInitial());

  final CashinRepository _repo;

  Future<void> lookupByCard(String cardCode) async {
    emit(const CashinLoading());

    final scanResult = await _repo.scanCard(cardCode);
    if (scanResult.isLeft()) {
      final msg = scanResult.fold((f) => f.message, (_) => '');
      emit(CashinError(msg));
      return;
    }

    final cardStatus = scanResult.fold((_) => '', (s) => s);
    if (cardStatus != 'ACTIVE') {
      final message = switch (cardStatus) {
        'SUSPENDED' => 'Cette carte est suspendue.',
        'BLOCKED' => 'Cette carte est bloquée (3 tentatives de PIN échouées).',
        'UNASSIGNED' => "Cette carte n'est pas encore activée.",
        _ => 'Carte invalide.',
      };
      emit(CashinError(message));
      return;
    }

    final orderResult = await _repo.getOrderByCard(cardCode);
    orderResult.fold(
      (f) => emit(
        CashinError(
          f.message == 'Order not found'
              ? 'Aucune commande en attente pour cet élève.'
              : f.message,
        ),
      ),
      (order) => emit(CashinOrderFound(order)),
    );
  }

  Future<void> lookupByCode(String code) async {
    emit(const CashinLoading());
    final result = await _repo.getOrderByCode(code);
    result.fold(
      (f) => emit(
        CashinError(
          f.message == 'Order not found'
              ? 'Aucune commande trouvée pour ce code.'
              : f.message,
        ),
      ),
      (order) => emit(CashinOrderFound(order)),
    );
  }

  Future<void> completeOrder(Order order, {required String pin}) async {
    emit(CashinCompleting(order));
    final result = await _repo.completeOrder(order.id, pin: pin);
    result.fold(
      (f) => emit(CashinError(_mapCompleteFailure(f))),
      (_) => emit(CashinCompleted(order)),
    );
  }

  String _mapCompleteFailure(Failure f) => switch (f.message) {
    'Invalid PIN' => 'Code PIN incorrect.',
    'Card is blocked after 3 failed PIN attempts' =>
      'Carte bloquée (3 tentatives de PIN échouées).',
    'Card PIN is required to complete this order' => 'Code PIN requis.',
    'Card is not active' => "Cette carte n'est pas active.",
    'Card PIN is not set' => "Le code PIN de cette carte n'est pas configuré.",
    _ => f.message,
  };

  void reset() => emit(const CashinInitial());
}
