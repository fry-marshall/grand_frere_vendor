class VendorStats {
  const VendorStats({
    required this.todayOrderCount,
    required this.todayRevenue,
    required this.cashToCollect,
  });

  final int todayOrderCount;
  final int todayRevenue;
  final int cashToCollect;
}
