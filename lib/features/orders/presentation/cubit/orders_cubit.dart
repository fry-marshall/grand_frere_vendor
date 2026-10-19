import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vendor_order.dart';
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
      (orders) => emit(_split(orders)),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }

  /// Re-fetches a single order and moves it to the right tab, instead of
  /// reloading the whole list — vendors are on metered mobile data.
  /// Falls back to a full reload when the list isn't loaded yet.
  Future<void> upsertOrder(String orderId) async {
    final current = state;
    final loaded = switch (current) {
      OrdersLoaded() => current,
      OrdersActionError(:final previous) => previous,
      _ => null,
    };
    if (loaded == null) return refresh();

    final result = await _repo.getOrderById(orderId);
    result.fold(
      (_) => emit(loaded.copyWith(clearAction: true)),
      (order) {
        final orders = [
          order,
          ...loaded.pending,
          ...loaded.validated,
          ...loaded.completed,
        ].where((o) => o.id != orderId || identical(o, order)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(_split(orders));
      },
    );
  }

  Future<void> validateOrder(String orderId) async {
    final loaded = state;
    if (loaded is! OrdersLoaded) return;
    emit(loaded.copyWith(actionOrderId: orderId));
    final result = await _repo.validateOrder(orderId);
    result.fold(
      (f) => emit(OrdersActionError(message: f.message, previous: loaded)),
      (_) => upsertOrder(orderId),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final loaded = state;
    if (loaded is! OrdersLoaded) return;
    emit(loaded.copyWith(actionOrderId: orderId));
    final result = await _repo.cancelOrder(orderId);
    result.fold(
      (f) => emit(OrdersActionError(message: f.message, previous: loaded)),
      (_) => upsertOrder(orderId),
    );
  }

  OrdersLoaded _split(List<VendorOrder> orders) => OrdersLoaded(
        pending: orders.where((o) => o.isPending).toList(),
        validated: orders.where((o) => o.isValidated).toList(),
        completed: orders
            .where((o) => o.isCompleted || o.isCancelled || o.status == 'EXPIRED')
            .toList(),
      );

  void dismissActionError() {
    final current = state;
    if (current is OrdersActionError) emit(current.previous);
  }
}
