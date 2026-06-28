import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    required this.studentFirstName,
    required this.studentLastName,
    required this.items,
    required this.createdAt,
    this.shortCode,
    this.expiresAt,
  });

  final String id;
  final String status;
  final String paymentMethod;
  final int totalAmount;
  final String studentFirstName;
  final String studentLastName;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String? shortCode;
  final DateTime? expiresAt;

  String get studentFullName => '$studentFirstName $studentLastName';

  bool get isCash => paymentMethod == 'CASH';
}
