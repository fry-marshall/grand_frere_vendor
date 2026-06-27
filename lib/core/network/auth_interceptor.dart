import 'package:dio/dio.dart';

import '../auth/auth_status.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage, this._authStatus);

  final TokenStorage _tokenStorage;
  final AuthStatus _authStatus;

  bool _isRefreshing = false;
  final _queue =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isRefreshEndpoint = path.contains('/auth/refresh');
    final isPasswordEndpoint = path.contains('/auth/change-password');

    if (!is401 || isRefreshEndpoint || isPasswordEndpoint) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _failAll(err, handler);
        return;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          headers: const {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      late final String newAccessToken;
      try {
        final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final tokens = refreshResponse.data!['data'] as Map<String, dynamic>;
        newAccessToken = tokens['accessToken'] as String;
        await _tokenStorage.updateTokens(
          accessToken: newAccessToken,
          refreshToken: tokens['refreshToken'] as String,
        );
      } on DioException catch (refreshErr) {
        if (refreshErr.response?.statusCode == 401) {
          await _failAll(err, handler);
        } else {
          handler.next(err);
          for (final item in _queue) {
            item.handler.next(err);
          }
        }
        return;
      }

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        final retried = await Dio().fetch<dynamic>(err.requestOptions);
        handler.resolve(retried);
      } on DioException catch (retryErr) {
        handler.next(retryErr);
      }

      for (final item in _queue) {
        item.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final r = await Dio().fetch<dynamic>(item.options);
          item.handler.resolve(r);
        } catch (e) {
          item.handler.next(err);
        }
      }
    } catch (_) {
      handler.next(err);
      for (final item in _queue) {
        item.handler.next(err);
      }
    } finally {
      _queue.clear();
      _isRefreshing = false;
    }
  }

  Future<void> _failAll(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _tokenStorage.clearTokens();
    _authStatus.notifyLogout();
    handler.next(err);
    for (final item in _queue) {
      item.handler.next(err);
    }
  }
}
