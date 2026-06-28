import '../../../../core/network/api_client.dart';
import '../models/vendor_balance_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_stats_model.dart';

abstract class VendorRemoteDataSource {
  Future<VendorModel> getVendor();
  Future<VendorStatsModel> getStats(String id);
  Future<VendorBalanceModel> getBalance(String id);
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  const VendorRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<VendorModel> getVendor() async {
    final res = await _client.get('/vendors/me');
    return VendorModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<VendorStatsModel> getStats(String id) async {
    final res = await _client.get('/vendors/$id/stats');
    return VendorStatsModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<VendorBalanceModel> getBalance(String id) async {
    final res = await _client.get('/vendors/$id/balance');
    return VendorBalanceModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }
}
