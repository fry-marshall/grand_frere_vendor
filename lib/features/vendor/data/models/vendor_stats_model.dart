import '../../domain/entities/vendor_stats.dart';

class VendorStatsModel {
  const VendorStatsModel({
    required this.todayOrderCount,
    required this.todayRevenue,
    required this.cashToCollect,
  });

  final int todayOrderCount;
  final int todayRevenue;
  final int cashToCollect;

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) =>
      VendorStatsModel(
        todayOrderCount: json['todayOrderCount'] as int,
        todayRevenue: json['todayRevenue'] as int,
        cashToCollect: json['cashToCollect'] as int,
      );

  VendorStats toDomain() => VendorStats(
        todayOrderCount: todayOrderCount,
        todayRevenue: todayRevenue,
        cashToCollect: cashToCollect,
      );
}
