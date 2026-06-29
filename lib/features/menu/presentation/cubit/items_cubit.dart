import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vendor_item.dart';
import '../../domain/repositories/items_repository.dart';
import 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit(this._repo) : super(ItemsInitial());

  final ItemsRepository _repo;
  String? _vendorId;

  Future<void> load(String vendorId) async {
    _vendorId = vendorId;
    emit(ItemsLoading());
    final result = await _repo.getItems();
    result.fold(
      (f) => emit(ItemsError(f.message)),
      (items) => emit(ItemsLoaded(items: items)),
    );
  }

  Future<void> refresh() async {
    if (_vendorId != null) await load(_vendorId!);
  }

  Future<void> createItem({
    required String name,
    required int price,
    String? description,
  }) async {
    if (_vendorId == null) return;
    final loaded = state is ItemsLoaded ? state as ItemsLoaded : null;
    emit(ItemsLoading());
    final result = await _repo.createItem(
      _vendorId!,
      name: name,
      price: price,
      description: description,
    );
    result.fold(
      (f) => loaded != null
          ? emit(ItemsActionError(message: f.message, previous: loaded))
          : emit(ItemsError(f.message)),
      (_) => load(_vendorId!),
    );
  }

  Future<void> updateItem(
    String id, {
    String? name,
    int? price,
    String? description,
  }) async {
    final loaded = state;
    if (loaded is! ItemsLoaded) return;
    emit(loaded.copyWith(actionItemId: id));
    final result = await _repo.updateItem(
      id,
      name: name,
      price: price,
      description: description,
    );
    result.fold(
      (f) => emit(ItemsActionError(message: f.message, previous: loaded)),
      (updated) {
        final newItems = loaded.items.map((i) => i.id == id ? updated : i).toList();
        emit(loaded.copyWith(items: newItems, clearAction: true));
      },
    );
  }

  Future<void> toggleStatus(VendorItem item) async {
    final loaded = state;
    if (loaded is! ItemsLoaded) return;
    final newStatus = item.isActive ? 'INACTIVE' : 'ACTIVE';
    emit(loaded.copyWith(actionItemId: item.id));
    final result = await _repo.updateItem(item.id, status: newStatus);
    result.fold(
      (f) => emit(ItemsActionError(message: f.message, previous: loaded)),
      (updated) {
        final newItems = loaded.items.map((i) => i.id == item.id ? updated : i).toList();
        emit(loaded.copyWith(items: newItems, clearAction: true));
      },
    );
  }

  Future<void> deleteItem(String id) async {
    final loaded = state;
    if (loaded is! ItemsLoaded) return;
    emit(loaded.copyWith(actionItemId: id));
    final result = await _repo.deleteItem(id);
    result.fold(
      (f) => emit(ItemsActionError(message: f.message, previous: loaded)),
      (_) {
        final newItems = loaded.items.where((i) => i.id != id).toList();
        emit(loaded.copyWith(items: newItems, clearAction: true));
      },
    );
  }

  Future<void> uploadImage(String id, String filePath) async {
    final loaded = state;
    if (loaded is! ItemsLoaded) return;
    emit(loaded.copyWith(actionItemId: id));
    final result = await _repo.uploadImage(id, filePath);
    result.fold(
      (f) => emit(ItemsActionError(message: f.message, previous: loaded)),
      (updated) {
        final newItems = loaded.items.map((i) => i.id == id ? updated : i).toList();
        emit(loaded.copyWith(items: newItems, clearAction: true));
      },
    );
  }

  void dismissActionError() {
    final current = state;
    if (current is ItemsActionError) emit(current.previous);
  }
}
