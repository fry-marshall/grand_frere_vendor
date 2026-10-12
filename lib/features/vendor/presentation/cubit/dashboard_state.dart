import '../../domain/entities/vendor_stats.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({required this.stats});
  final VendorStats stats;
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
}
