import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/vendor_item_model.dart';

abstract class ItemsRemoteDataSource {
  Future<List<VendorItemModel>> getItems();
  Future<VendorItemModel> createItem(
    String vendorId, {
    required String name,
    required int price,
    String? description,
  });
  Future<VendorItemModel> updateItem(
    String id, {
    String? name,
    int? price,
    String? description,
    String? status,
  });
  Future<void> deleteItem(String id);
  Future<VendorItemModel> uploadImage(String id, String filePath);
}

class ItemsRemoteDataSourceImpl implements ItemsRemoteDataSource {
  const ItemsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<VendorItemModel>> getItems() async {
    final res = await _client.get('/items', query: {'limit': '100'});
    final data = res.data['data'] as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => VendorItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VendorItemModel> createItem(
    String vendorId, {
    required String name,
    required int price,
    String? description,
  }) async {
    final body = <String, dynamic>{'name': name, 'price': price};
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    final res = await _client.post('/items/vendor/$vendorId', data: body);
    return VendorItemModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<VendorItemModel> updateItem(
    String id, {
    String? name,
    int? price,
    String? description,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;
    final res = await _client.put('/items/$id', data: body);
    return VendorItemModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client.delete('/items/$id');
  }

  @override
  Future<VendorItemModel> uploadImage(String id, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _client.put('/items/$id/image', data: formData);
    return VendorItemModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
