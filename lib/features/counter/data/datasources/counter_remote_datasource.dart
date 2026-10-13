import '../../../../core/network/api_client.dart';
import '../models/counter_preview_model.dart';

abstract class CounterRemoteDataSource {
  Future<CounterPreviewModel> preview(String cardCode);
  Future<int> sell({
    required String cardCode,
    required Map<String, int> quantities,
    required String pin,
  });
}

class CounterRemoteDataSourceImpl implements CounterRemoteDataSource {
  const CounterRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<CounterPreviewModel> preview(String cardCode) async {
    final res = await _client.get(
      '/orders/counter/preview',
      query: {'cardCode': cardCode},
    );
    return CounterPreviewModel.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<int> sell({
    required String cardCode,
    required Map<String, int> quantities,
    required String pin,
  }) async {
    final res = await _client.post(
      '/orders/counter',
      data: {
        'cardCode': cardCode,
        'items': [
          for (final e in quantities.entries)
            {'itemId': e.key, 'quantity': e.value},
        ],
        'pin': pin,
      },
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return (data['totalAmount'] as num).toInt();
  }
}
