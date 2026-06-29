import '../../domain/entities/app_notification.dart';

sealed class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  NotificationsLoaded(this.notifications);
  final List<AppNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsLoaded withUpdated(List<AppNotification> items) =>
      NotificationsLoaded(items);
}

class NotificationsError extends NotificationsState {
  NotificationsError(this.message);
  final String message;
}
