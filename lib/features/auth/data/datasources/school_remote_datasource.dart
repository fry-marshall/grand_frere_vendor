import '../../../../core/network/api_client.dart';
import '../models/school_model.dart';

abstract class SchoolRemoteDataSource {
  Future<List<SchoolModel>> getSchools();
}

class SchoolRemoteDataSourceImpl implements SchoolRemoteDataSource {
  const SchoolRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<SchoolModel>> getSchools() async {
    final response = await _client.get('/schools');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SchoolModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
