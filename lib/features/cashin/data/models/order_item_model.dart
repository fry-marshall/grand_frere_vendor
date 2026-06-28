import '../../domain/entities/order_item.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final int unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;
    return OrderItemModel(
      name: item['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as int,
    );
  }

  OrderItem toDomain() => OrderItem(
        name: name,
        quantity: quantity,
        unitPrice: unitPrice,
      );
}
