class VendorOrderItem {
  const VendorOrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final int unitPrice;

  int get subtotal => quantity * unitPrice;
}
