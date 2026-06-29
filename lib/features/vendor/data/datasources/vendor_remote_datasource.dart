import '../../../../core/network/api_client.dart';
import '../models/vendor_balance_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_stats_model.dart';

abstract class VendorRemoteDataSource {
  Future<VendorModel> getVendor();
  Future<VendorStatsModel> getStats(String id);
  Future<VendorBalanceModel> getBalance(String id);
  Future<VendorModel> updateVendor(
    String id, {
    String? shopName,
    String? waveNumber,
    String? openingTime,
    String? closingTime,
  });
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

  @override
  Future<VendorModel> updateVendor(
    String id, {
    String? shopName,
    String? waveNumber,
    String? openingTime,
    String? closingTime,
  }) async {
    final body = <String, dynamic>{};
    if (shopName != null) body['shopName'] = shopName;
    if (waveNumber != null) body['waveNumber'] = waveNumber;
    if (openingTime != null) body['openingTime'] = openingTime;
    if (closingTime != null) body['closingTime'] = closingTime;
    final res = await _client.put('/vendors/$id', data: body);
    return VendorModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
