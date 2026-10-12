class WalletMovement {
  const WalletMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
    this.orderId,
    this.withdrawalId,
    this.reason,
  });

  final String id;
  final String type;

  /// Signed delta: positive for a credit, negative for a debit.
  final int amount;
  final int balanceAfter;
  final String? orderId;
  final String? withdrawalId;
  final String? reason;
  final DateTime createdAt;

  bool get isCredit => amount >= 0;
  bool get isCashin => type == 'CASHIN';
  bool get isWithdrawal => type == 'WITHDRAWAL';
  bool get isWithdrawalRefund => type == 'WITHDRAWAL_REFUND';
  bool get isAdjustment => type == 'ADJUSTMENT';
}
