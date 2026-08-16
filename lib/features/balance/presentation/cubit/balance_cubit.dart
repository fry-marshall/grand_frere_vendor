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
    final balanceResult = await balanceFuture;
    final withdrawalsResult = await withdrawalsFuture;

    if (balanceResult.isLeft()) {
      emit(BalanceError(balanceResult.fold((f) => f.message, (_) => '')));
      return;
    }

    emit(
      BalanceLoaded(
        balance: balanceResult.getRight().toNullable()!,
        withdrawals: withdrawalsResult.getRight().toNullable() ?? [],
      ),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }

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
