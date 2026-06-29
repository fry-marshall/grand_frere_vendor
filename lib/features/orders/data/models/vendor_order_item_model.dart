import '../../domain/entities/vendor_order_item.dart';

class VendorOrderItemModel extends VendorOrderItem {
  const VendorOrderItemModel({
    required super.name,
    required super.quantity,
    required super.unitPrice,
  });

  factory VendorOrderItemModel.fromJson(Map<String, dynamic> json) =>
      VendorOrderItemModel(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        unitPrice: json['unitPrice'] as int,
      );
}
