import 'package:flutter_bloc/flutter_bloc.dart';

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

    emit(BalanceLoaded(
      balance: balanceResult.getRight().toNullable()!,
      withdrawals: withdrawalsResult.getRight().toNullable() ?? [],
    ));
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
    result.fold(
      (f) => emit(BalanceActionError(message: f.message, previous: loaded)),
      (_) => load(_vendorId!),
    );
  }

  void dismissError() {
    final current = state;
    if (current is BalanceActionError) emit(current.previous);
  }
}
