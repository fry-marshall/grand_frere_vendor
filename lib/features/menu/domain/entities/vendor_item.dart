class VendorItem {
  const VendorItem({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.step,
    required this.status,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String vendorId;
  final String name;

  /// Minimum price (the unit price when the item is fixed-price).
  final int price;

  /// Increment above the minimum price (e.g. 50, 75, 100… for a step of 25).
  /// Equal to the price: fixed-price item, sold by quantity.
  final int step;

  final String? description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  bool get isActive => status == 'ACTIVE';

  /// +/− changes the amount (not the quantity) when the step differs from the price.
  bool get isVariablePrice => step != price;

  /// Amount after `units` taps on +: the minimum, then one step per tap.
  /// For a fixed-price item this is price × quantity.
  int amountFor(int units) => units <= 0 ? 0 : price + (units - 1) * step;
}
