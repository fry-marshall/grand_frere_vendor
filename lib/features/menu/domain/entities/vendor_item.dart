class VendorItem {
  const VendorItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.status,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String vendorId;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  bool get isActive => status == 'ACTIVE';
}
