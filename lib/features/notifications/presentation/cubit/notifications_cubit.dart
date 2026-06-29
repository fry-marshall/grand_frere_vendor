import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repo) : super(NotificationsInitial());

  final NotificationsRepository _repo;

  Future<void> load() async {
    emit(NotificationsLoading());
    final result = await _repo.getNotifications();
    result.fold(
      (f) => emit(NotificationsError(f.message)),
      (items) => emit(NotificationsLoaded(items)),
    );
  }

  Future<void> refresh() => load();

  Future<void> markRead(String id) async {
    final loaded = state;
    if (loaded is! NotificationsLoaded) return;
    await _repo.markRead(id);
    final updated =
        loaded.notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    emit(loaded.withUpdated(updated));
  }

  Future<void> markAllRead() async {
    final loaded = state;
    if (loaded is! NotificationsLoaded) return;
    await _repo.markAllRead();
    final updated = loaded.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(loaded.withUpdated(updated));
  }
}
