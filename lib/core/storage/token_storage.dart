import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) =>
      Future.wait([
        _storage.write(key: _accessKey, value: accessToken),
        _storage.write(key: _refreshKey, value: refreshToken),
        _storage.write(key: _roleKey, value: role),
        _storage.write(key: _userIdKey, value: _extractSub(accessToken) ?? ''),
      ]);

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      Future.wait([
        _storage.write(key: _accessKey, value: accessToken),
        _storage.write(key: _refreshKey, value: refreshToken),
      ]);

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> clearTokens() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
        _storage.delete(key: _roleKey),
        _storage.delete(key: _userIdKey),
      ]);

  static String? _extractSub(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final padding = (4 - parts[1].length % 4) % 4;
      final padded = parts[1] + '=' * padding;
      final bytes = base64Url.decode(padded);
      final payload = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
