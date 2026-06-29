import '../../../vendor/domain/entities/vendor_balance.dart';
import '../../domain/entities/vendor_withdrawal.dart';

sealed class BalanceState {}

class BalanceInitial extends BalanceState {}

class BalanceLoading extends BalanceState {}

class BalanceLoaded extends BalanceState {
  BalanceLoaded({
    required this.balance,
    required this.withdrawals,
    this.isCreating = false,
  });

  final VendorBalance balance;
  final List<VendorWithdrawal> withdrawals;
  final bool isCreating;

  BalanceLoaded copyWith({
    VendorBalance? balance,
    List<VendorWithdrawal>? withdrawals,
    bool? isCreating,
  }) {
    return BalanceLoaded(
      balance: balance ?? this.balance,
      withdrawals: withdrawals ?? this.withdrawals,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

class BalanceError extends BalanceState {
  BalanceError(this.message);
  final String message;
}

class BalanceActionError extends BalanceState {
  BalanceActionError({required this.message, required this.previous});
  final String message;
  final BalanceLoaded previous;
}
