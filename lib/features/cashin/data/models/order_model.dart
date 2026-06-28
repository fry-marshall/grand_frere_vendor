import '../../domain/entities/order.dart';
import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
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
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String? shortCode;
  final DateTime? expiresAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final user = student['user'] as Map<String, dynamic>;
    final rawItems = json['items'] as List<dynamic>;
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      totalAmount: json['totalAmount'] as int,
      studentFirstName: user['firstName'] as String,
      studentLastName: user['lastName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shortCode: json['shortCode'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Order toDomain() => Order(
        id: id,
        status: status,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        studentFirstName: studentFirstName,
        studentLastName: studentLastName,
        createdAt: createdAt,
        shortCode: shortCode,
        expiresAt: expiresAt,
        items: items.map((e) => e.toDomain()).toList(),
      );
}
