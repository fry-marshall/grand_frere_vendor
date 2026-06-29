import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(OrdersInitial());

  final OrdersRepository _repo;
  String? _vendorId;

  Future<void> load(String vendorId) async {
    _vendorId = vendorId;
    emit(OrdersLoading());
    final result = await _repo.getOrders(vendorId);
    result.fold(
      (f) => emit(OrdersError(f.message)),
      (orders) => emit(OrdersLoaded(
        pending: orders.where((o) => o.isPending).toList(),
        validated: orders.where((o) => o.isValidated).toList(),
        completed: orders
            .where((o) => o.isCompleted || o.isCancelled || o.status == 'EXPIRED')
            .toList(),
      )),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }

  Future<void> validateOrder(String orderId) async {
    final loaded = state;
    if (loaded is! OrdersLoaded) return;
    emit(loaded.copyWith(actionOrderId: orderId));
    final result = await _repo.validateOrder(orderId);
    result.fold(
      (f) => emit(OrdersActionError(message: f.message, previous: loaded)),
      (_) => load(_vendorId!),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final loaded = state;
    if (loaded is! OrdersLoaded) return;
    emit(loaded.copyWith(actionOrderId: orderId));
    final result = await _repo.cancelOrder(orderId);
    result.fold(
      (f) => emit(OrdersActionError(message: f.message, previous: loaded)),
      (_) => load(_vendorId!),
    );
  }

  void dismissActionError() {
    final current = state;
    if (current is OrdersActionError) emit(current.previous);
  }
}
