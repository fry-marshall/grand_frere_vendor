import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.messages});

  final int statusCode;
  final List<String> messages;

  String get firstMessage =>
      messages.isNotEmpty ? messages.first : 'An unexpected error occurred';

  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 400;

  factory ApiException.fromDioException(DioException e) {
    const networkTypes = {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    };
    if (networkTypes.contains(e.type)) {
      return const ApiException(
        statusCode: 0,
        messages: ['No internet connection'],
      );
    }

    final statusCode = e.response?.statusCode ?? 0;
    return ApiException(
      statusCode: statusCode,
      messages: _parse(e.response?.data),
    );
  }

  static List<String> _parse(dynamic data) {
    if (data is! Map<String, dynamic>) return ['An unexpected error occurred'];
    final raw = data['message'];
    if (raw is List) return raw.map((m) => m.toString()).toList();
    if (raw is String) return [raw];
    return ['An unexpected error occurred'];
  }

  @override
  String toString() => 'ApiException($statusCode): $firstMessage';
}
