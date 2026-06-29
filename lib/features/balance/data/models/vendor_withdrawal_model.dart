import '../../domain/entities/vendor_withdrawal.dart';

class VendorWithdrawalModel extends VendorWithdrawal {
  const VendorWithdrawalModel({
    required super.id,
    required super.vendorId,
    required super.amount,
    required super.currency,
    required super.waveNumber,
    required super.status,
    required super.createdAt,
    super.paystackRef,
  });

  factory VendorWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return VendorWithdrawalModel(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      waveNumber: json['waveNumber'] as String,
      paystackRef: json['paystackRef'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
