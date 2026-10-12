import '../../domain/entities/wallet_movement.dart';

class WalletMovementModel extends WalletMovement {
  const WalletMovementModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.balanceAfter,
    required super.createdAt,
    super.orderId,
    super.withdrawalId,
    super.reason,
  });

  factory WalletMovementModel.fromJson(Map<String, dynamic> json) {
    return WalletMovementModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      balanceAfter: (json['balanceAfter'] as num).toInt(),
      orderId: json['orderId'] as String?,
      withdrawalId: json['withdrawalId'] as String?,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
