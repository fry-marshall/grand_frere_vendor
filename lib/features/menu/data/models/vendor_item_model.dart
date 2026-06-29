import '../../domain/entities/vendor_item.dart';

class VendorItemModel extends VendorItem {
  const VendorItemModel({
    required super.id,
    required super.vendorId,
    required super.name,
    required super.price,
    required super.status,
    required super.createdAt,
    super.description,
    super.imageUrl,
  });

  factory VendorItemModel.fromJson(Map<String, dynamic> json) {
    return VendorItemModel(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
