import '../../domain/entities/vendor_order.dart';
import 'vendor_order_item_model.dart';

class VendorOrderModel extends VendorOrder {
  const VendorOrderModel({
    required super.id,
    required super.status,
    required super.paymentMethod,
    required super.totalAmount,
    required super.createdAt,
    required super.items,
    required super.studentFirstName,
    required super.studentLastName,
    required super.studentClass,
    super.shortCode,
    super.scheduledFor,
    super.expiresAt,
  });

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final user = student['user'] as Map<String, dynamic>;
    final itemsJson = json['items'] as List<dynamic>;

    return VendorOrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      totalAmount: json['totalAmount'] as int,
      shortCode: json['shortCode'] as String?,
      scheduledFor: json['scheduledFor'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: itemsJson
          .map((e) => VendorOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      studentFirstName: user['firstName'] as String,
      studentLastName: user['lastName'] as String,
      studentClass: (student['class'] ?? '') as String,
    );
  }
}
