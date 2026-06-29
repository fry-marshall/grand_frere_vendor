import '../../../../core/network/api_client.dart';
import '../../../vendor/data/models/vendor_balance_model.dart';
import '../models/vendor_withdrawal_model.dart';

abstract class BalanceRemoteDataSource {
  Future<VendorBalanceModel> getBalance(String vendorId);
  Future<List<VendorWithdrawalModel>> getWithdrawals(String vendorId);
  Future<VendorWithdrawalModel> createWithdrawal(
    String vendorId, {
    required int amount,
    required String waveNumber,
  });
}

class BalanceRemoteDataSourceImpl implements BalanceRemoteDataSource {
  const BalanceRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<VendorBalanceModel> getBalance(String vendorId) async {
    final res = await _client.get('/vendors/$vendorId/balance');
    return VendorBalanceModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<VendorWithdrawalModel>> getWithdrawals(String vendorId) async {
    final res = await _client.get(
      '/vendors/$vendorId/withdrawals',
      query: {'limit': '50'},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => VendorWithdrawalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VendorWithdrawalModel> createWithdrawal(
    String vendorId, {
    required int amount,
    required String waveNumber,
  }) async {
    final res = await _client.post(
      '/withdrawals/vendor/$vendorId',
      data: {'amount': amount, 'waveNumber': waveNumber},
    );
    return VendorWithdrawalModel.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }
}
