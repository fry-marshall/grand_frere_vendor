import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  AuthTokens toDomain() => AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
