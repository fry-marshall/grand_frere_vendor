import 'vendor_order_item.dart';

class VendorOrder {
  const VendorOrder({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    required this.studentFirstName,
    required this.studentLastName,
    required this.studentClass,
    this.shortCode,
    this.scheduledFor,
    this.expiresAt,
  });

  final String id;
  final String status;
  final String paymentMethod;
  final int totalAmount;
  final DateTime createdAt;
  final List<VendorOrderItem> items;
  final String studentFirstName;
  final String studentLastName;
  final String studentClass;
  final String? shortCode;
  final String? scheduledFor;
  final DateTime? expiresAt;

  String get studentFullName => '$studentFirstName $studentLastName';
  bool get isPending => status == 'PENDING';
  bool get isValidated => status == 'VALIDATED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCash => paymentMethod == 'CASH';

  String get itemsSummary =>
      items.take(2).map((i) => '${i.quantity}× ${i.name}').join(' · ');
}
