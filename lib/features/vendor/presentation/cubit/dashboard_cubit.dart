import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/vendor_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(const DashboardInitial());

  final VendorRepository _repo;
  String? _vendorId;

  /// Today's KPIs only — the balance lives in BalanceCubit, the single
  /// source for both the home card and the balance screen.
  Future<void> load(String vendorId) async {
    _vendorId = vendorId;
    emit(const DashboardLoading());

    final result = await _repo.getStats(vendorId);
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (stats) => emit(DashboardLoaded(stats: stats)),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }
}
