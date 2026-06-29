class VendorWithdrawal {
  const VendorWithdrawal({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.currency,
    required this.waveNumber,
    required this.status,
    required this.createdAt,
    this.paystackRef,
  });

  final String id;
  final String vendorId;
  final int amount;
  final String currency;
  final String waveNumber;
  final String? paystackRef;
  final String status;
  final DateTime createdAt;

  bool get isPending => status == 'PENDING';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';
}
