import '../../domain/entities/vendor_order.dart';

sealed class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  OrdersLoaded({
    required this.pending,
    required this.validated,
    required this.completed,
    this.actionOrderId,
  });

  final List<VendorOrder> pending;
  final List<VendorOrder> validated;
  final List<VendorOrder> completed;
  final String? actionOrderId;

  OrdersLoaded copyWith({
    List<VendorOrder>? pending,
    List<VendorOrder>? validated,
    List<VendorOrder>? completed,
    String? actionOrderId,
    bool clearAction = false,
  }) =>
      OrdersLoaded(
        pending: pending ?? this.pending,
        validated: validated ?? this.validated,
        completed: completed ?? this.completed,
        actionOrderId: clearAction ? null : (actionOrderId ?? this.actionOrderId),
      );
}

class OrdersError extends OrdersState {
  OrdersError(this.message);
  final String message;
}

class OrdersActionError extends OrdersState {
  OrdersActionError({required this.message, required this.previous});
  final String message;
  final OrdersLoaded previous;
}
