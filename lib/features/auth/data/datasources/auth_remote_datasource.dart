import '../../../../core/network/api_client.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String phone,
    required String password,
  });

  Future<AuthTokensModel> signupVendor({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String shopName,
    required String schoolId,
    String? waveNumber,
  });

  Future<String?> forgotPassword({required String phone});

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<AuthTokensModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/signin',
      data: {'phone': phone, 'password': password},
    );
    return AuthTokensModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthTokensModel> signupVendor({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String shopName,
    required String schoolId,
    String? waveNumber,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'password': password,
      'shopName': shopName,
      'schoolId': schoolId,
      'waveNumber': waveNumber,
    };
    final response = await _client.post('/auth/signup/vendor', data: body);
    return AuthTokensModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<String?> forgotPassword({required String phone}) async {
    final response = await _client.post(
      '/auth/forgot-password',
      data: {'phone': phone},
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['code'] as String?;
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/reset-password',
      data: {'phone': phone, 'code': code, 'newPassword': newPassword},
    );
  }
}
