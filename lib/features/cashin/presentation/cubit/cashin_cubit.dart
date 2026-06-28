import 'package:flutter_bloc/flutter_bloc.dart';

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
      (f) => emit(CashinError(
        f.message == 'Order not found'
            ? 'Aucune commande en attente pour cet élève.'
            : f.message,
      )),
      (order) => emit(CashinOrderFound(order)),
    );
  }

  Future<void> lookupByCode(String code) async {
    emit(const CashinLoading());
    final result = await _repo.getOrderByCode(code);
    result.fold(
      (f) => emit(CashinError(
        f.message == 'Order not found'
            ? 'Aucune commande trouvée pour ce code.'
            : f.message,
      )),
      (order) => emit(CashinOrderFound(order)),
    );
  }

  Future<void> completeOrder(Order order) async {
    emit(CashinCompleting(order));
    final result = await _repo.completeOrder(order.id);
    result.fold(
      (f) => emit(CashinError(f.message)),
      (_) => emit(CashinCompleted(order)),
    );
  }

  void reset() => emit(const CashinInitial());
}
