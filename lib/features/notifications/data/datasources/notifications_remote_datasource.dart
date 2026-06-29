import '../../../../core/network/api_client.dart';
import '../models/app_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    final res = await _client.get('/notifications', query: {'limit': '50'});
    final data = res.data['data'] as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAllRead() async {
    await _client.put('/notifications/read-all');
  }

  @override
  Future<void> markRead(String id) async {
    await _client.put('/notifications/$id/read');
  }
}
