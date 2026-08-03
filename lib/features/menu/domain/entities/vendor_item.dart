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
    this.pendingImageUrl,
  });

  final String id;
  final String vendorId;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final String? pendingImageUrl;
  final String status;
  final DateTime createdAt;

  bool get isActive => status == 'ACTIVE';

  /// A newly uploaded photo is awaiting admin approval — the live [imageUrl]
  /// is still what's shown to students/parents until it's reviewed.
  bool get hasPendingImage => pendingImageUrl != null;
}
