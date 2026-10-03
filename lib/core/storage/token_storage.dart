import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // resetOnError: on Android, Auto Backup can restore the encrypted prefs
  // onto a new install/device without the Keystore key that encrypted them —
  // every read then throws. Wiping the storage turns that into a plain
  // logged-out state instead of an exception on every launch.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  // Writes are sequential, not Future.wait-parallel: concurrent Keychain
  // writes on iOS can race and silently drop one of the values without
  // throwing, leaving e.g. the refresh token unpersisted after a "successful"
  // save.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(
      key: _userIdKey,
      value: _extractSub(accessToken) ?? '',
    );
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
  }

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
