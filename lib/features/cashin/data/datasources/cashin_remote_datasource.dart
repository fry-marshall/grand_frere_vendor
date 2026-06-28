import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/pending_order_model.dart';

abstract class CashinRemoteDataSource {
  Future<String> scanCard(String cardCode);
  Future<OrderModel> getOrderByCard(String cardCode);
  Future<OrderModel> getOrderByCode(String code);
  Future<void> completeOrder(String orderId);
  Future<List<PendingOrderModel>> getPendingOrders(String vendorId);
}

class CashinRemoteDataSourceImpl implements CashinRemoteDataSource {
  const CashinRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<String> scanCard(String cardCode) async {
    final res = await _client.post('/auth/scan-card', data: {'code': cardCode});
    final data = res.data['data'] as Map<String, dynamic>;
    return data['status'] as String;
  }

  @override
  Future<OrderModel> getOrderByCard(String cardCode) async {
    final res = await _client.get(
      '/orders/by-card',
      query: {'cardCode': cardCode},
    );
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> getOrderByCode(String code) async {
    final res = await _client.get(
      '/orders/by-code',
      query: {'code': code},
    );
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> completeOrder(String orderId) async {
    await _client.put('/orders/$orderId/complete');
  }

  @override
  Future<List<PendingOrderModel>> getPendingOrders(String vendorId) async {
    final res = await _client.get('/vendors/$vendorId/orders', query: {'limit': '50'});
    final data = res.data['data'] as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => PendingOrderModel.fromJson(e as Map<String, dynamic>))
        .where((m) => m.shortCode.isNotEmpty)
        .toList();
  }
}
