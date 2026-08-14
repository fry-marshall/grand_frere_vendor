import '../../domain/entities/vendor_stats.dart';

class VendorStatsModel {
  const VendorStatsModel({
    required this.todayOrderCount,
    required this.todayRevenue,
  });

  final int todayOrderCount;
  final int todayRevenue;

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) =>
      VendorStatsModel(
        todayOrderCount: json['todayOrderCount'] as int,
        todayRevenue: json['todayRevenue'] as int,
      );

  VendorStats toDomain() =>
      VendorStats(todayOrderCount: todayOrderCount, todayRevenue: todayRevenue);
}
