import '../../../../core/network/api_client.dart';
import '../models/vendor_order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<VendorOrderModel>> getOrders(String vendorId);
  Future<void> validateOrder(String orderId);
  Future<void> cancelOrder(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<VendorOrderModel>> getOrders(String vendorId) async {
    final res = await _client.get(
      '/vendors/$vendorId/orders',
      query: {'limit': '100'},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => VendorOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> validateOrder(String orderId) async {
    await _client.put('/orders/$orderId/validate');
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _client.put('/orders/$orderId/cancel');
  }
}
