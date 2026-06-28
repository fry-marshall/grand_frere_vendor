import '../../domain/entities/vendor_balance.dart';

class VendorBalanceModel {
  const VendorBalanceModel({required this.balance, required this.currency});

  final int balance;
  final String currency;

  factory VendorBalanceModel.fromJson(Map<String, dynamic> json) =>
      VendorBalanceModel(
        balance: json['balance'] as int,
        currency: json['currency'] as String,
      );

  VendorBalance toDomain() => VendorBalance(balance: balance, currency: currency);
}
