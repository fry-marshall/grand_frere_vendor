import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repositories/balance_repository.dart';
import 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repo) : super(BalanceInitial());

  final BalanceRepository _repo;
  String? _vendorId;

  Future<void> load(String vendorId) async {
    _vendorId = vendorId;
    emit(BalanceLoading());

    final balanceFuture = _repo.getBalance(vendorId);
    final withdrawalsFuture = _repo.getWithdrawals(vendorId);
    final movementsFuture = _repo.getMovements(vendorId);
    final balanceResult = await balanceFuture;
    final withdrawalsResult = await withdrawalsFuture;
    final movementsResult = await movementsFuture;

    if (balanceResult.isLeft()) {
      emit(BalanceError(balanceResult.fold((f) => f.message, (_) => '')));
      return;
    }

    emit(
      BalanceLoaded(
        balance: balanceResult.getRight().toNullable()!,
        withdrawals: withdrawalsResult.getRight().toNullable() ?? [],
        movements: movementsResult.getRight().toNullable() ?? [],
      ),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }

  /// A sale only moves the balance and adds a movement: fetch the balance and
  /// the latest few movements instead of reloading every list — vendors are
  /// on metered mobile data. Withdrawals are untouched by a sale.
  Future<void> refreshAfterSale() async {
    final loaded = state;
    if (loaded is! BalanceLoaded) return refresh();

    final balanceFuture = _repo.getBalance(_vendorId!);
    final movementsFuture = _repo.getMovements(
      _vendorId!,
      limit: _latestMovementsLimit,
    );
    final balanceResult = await balanceFuture;
    final movementsResult = await movementsFuture;
    if (balanceResult.isLeft()) return;

    final latest = movementsResult.getRight().toNullable() ?? [];
    final latestIds = latest.map((m) => m.id).toSet();
    emit(
      loaded.copyWith(
        balance: balanceResult.getRight().toNullable()!,
        movements: [
          ...latest,
          ...loaded.movements.where((m) => !latestIds.contains(m.id)),
        ],
      ),
    );
  }

  static const _latestMovementsLimit = 5;

  Future<void> createWithdrawal({
    required int amount,
    required String waveNumber,
  }) async {
    final loaded = state;
    if (loaded is! BalanceLoaded) return;
    emit(loaded.copyWith(isCreating: true));
    final result = await _repo.createWithdrawal(
      _vendorId!,
      amount: amount,
      waveNumber: waveNumber,
    );
    await result.fold(
      (f) async => emit(
        BalanceActionError(
          message: _mapCreateWithdrawalFailure(f),
          previous: loaded,
        ),
      ),
      (_) => load(_vendorId!),
    );
  }

  String _mapCreateWithdrawalFailure(Failure f) => switch (f.message) {
    'Insufficient vendor wallet balance' =>
      'Solde insuffisant pour ce retrait.',
    'Vendor wallet not found' => "Aucun solde disponible pour l'instant.",
    _ => f.message,
  };

  void dismissError() {
    final current = state;
    if (current is BalanceActionError) emit(current.previous);
  }
}
