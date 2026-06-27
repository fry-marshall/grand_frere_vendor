import 'dart:convert';

import '../auth/user_role.dart';

abstract class JwtDecoder {
  static Map<String, dynamic> _payload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('Invalid JWT');
    final normalized = base64Url.normalize(parts[1]);
    return jsonDecode(utf8.decode(base64Url.decode(normalized)))
        as Map<String, dynamic>;
  }

  static UserRole? extractRole(String token) {
    try {
      return switch (_payload(token)['role'] as String?) {
        'PARENT' => UserRole.parent,
        'STUDENT' => UserRole.student,
        'VENDOR' => UserRole.vendor,
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}
