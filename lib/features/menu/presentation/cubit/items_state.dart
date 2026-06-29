import '../../domain/entities/vendor_item.dart';

sealed class ItemsState {}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  ItemsLoaded({required this.items, this.actionItemId});

  final List<VendorItem> items;
  final String? actionItemId;

  List<VendorItem> get active => items.where((i) => i.isActive).toList();
  List<VendorItem> get inactive => items.where((i) => !i.isActive).toList();

  ItemsLoaded copyWith({
    List<VendorItem>? items,
    String? actionItemId,
    bool clearAction = false,
  }) {
    return ItemsLoaded(
      items: items ?? this.items,
      actionItemId: clearAction ? null : (actionItemId ?? this.actionItemId),
    );
  }
}

class ItemsError extends ItemsState {
  ItemsError(this.message);
  final String message;
}

class ItemsActionError extends ItemsState {
  ItemsActionError({required this.message, required this.previous});
  final String message;
  final ItemsLoaded previous;
}
