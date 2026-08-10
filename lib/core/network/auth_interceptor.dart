// ignore_for_file: prefer_initializing_formals — constructor uses named
// params (tokenStorage/onSessionExpired) for a self-documenting call site.
import 'package:dio/dio.dart';
import 'package:nutq/core/network/token_storage.dart';

/// Attaches the bearer access token to outgoing requests and transparently
/// refreshes it on a 401, retrying the original request exactly once.
///
/// Extends [QueuedInterceptor] so concurrent requests that all 401 at once
/// (e.g. several in-flight calls when the access token expires) share a
/// single refresh attempt instead of each firing their own /auth/refresh
/// call against the backend.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  }) : _tokenStorage = tokenStorage,
       _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  final Future<void> Function() _onSessionExpired;
  late final Dio _dio;

  /// Must be called once with the [Dio] instance this interceptor is
  /// attached to, so it can replay requests and call /auth/refresh.
  void attach(Dio dio) => _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['isRefreshCall'] != true) {
      final token = await _tokenStorage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRefreshCall = err.requestOptions.extra['isRefreshCall'] == true;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (err.response?.statusCode != 401 || isRefreshCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) {
      await _expireSession(handler, err);
      return;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
          extra: {'isRefreshCall': true},
        ),
      );
      final data = response.data!;
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      final retryOptions = err.requestOptions;
      retryOptions.extra['retried'] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _expireSession(handler, err);
    }
  }

  Future<void> _expireSession(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    await _tokenStorage.clear();
    await _onSessionExpired();
    handler.next(err);
  }
}
