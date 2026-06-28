import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vendor_balance.dart';
import '../../domain/entities/vendor_stats.dart';
import '../../domain/repositories/vendor_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(const DashboardInitial());

  final VendorRepository _repo;

  Future<void> load(String vendorId) async {
    emit(const DashboardLoading());

    final statsFuture = _repo.getStats(vendorId);
    final balanceFuture = _repo.getBalance(vendorId);

    final statsResult = await statsFuture;
    final balanceResult = await balanceFuture;

    final VendorStats? stats = statsResult.fold((_) => null, (s) => s);
    final VendorBalance? balance = balanceResult.fold((_) => null, (b) => b);

    if (stats == null || balance == null) {
      final msg = statsResult.isLeft()
          ? statsResult.fold((f) => f.message, (_) => 'Erreur.')
          : balanceResult.fold((f) => f.message, (_) => 'Erreur.');
      emit(DashboardError(msg));
    } else {
      emit(DashboardLoaded(stats: stats, balance: balance));
    }
  }
}
