import '../../../../core/network/api_client.dart';
import '../../domain/entities/counter_sale.dart';
import '../models/counter_preview_model.dart';

abstract class CounterRemoteDataSource {
  Future<CounterPreviewModel> preview(String cardCode);
  Future<CounterSale> sell({
    required String cardCode,
    required List<({String itemId, int quantity, int? amount})> lines,
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
  Future<CounterSale> sell({
    required String cardCode,
    required List<({String itemId, int quantity, int? amount})> lines,
    required String pin,
  }) async {
    final res = await _client.post(
      '/orders/counter',
      data: {
        'cardCode': cardCode,
        'items': [
          for (final line in lines)
            {
              'itemId': line.itemId,
              'quantity': line.quantity,
              if (line.amount != null) 'amount': line.amount,
            },
        ],
        'pin': pin,
      },
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return CounterSale(
      orderId: data['id'] as String,
      total: (data['totalAmount'] as num).toInt(),
    );
  }
}
