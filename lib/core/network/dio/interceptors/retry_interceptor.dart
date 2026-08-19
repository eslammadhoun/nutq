import 'package:dio/dio.dart';

/// Retries transient failures with exponential backoff
/// Never retries 4xx (client errors) — only network/timeout/5xx
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 16),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  late final Dio _dio;

  /// Must be called once with the [Dio] instance this interceptor is attached to
  void attach(Dio dio) => _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (!_shouldRetry(err, retryCount)) {
      handler.next(err);
      return;
    }

    final delay = _calculateDelay(retryCount);
    await Future.delayed(delay);

    final retryOptions = err.requestOptions;
    retryOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int retryCount) {
    if (retryCount >= maxRetries) return false;

    // Only retry transient errors
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionTimeout:
        return true;
      case DioExceptionType.badResponse:
        // Retry 5xx only
        return (err.response?.statusCode ?? 0) >= 500;
      default:
        return false;
    }
  }

  Duration _calculateDelay(int retryCount) {
    final exponential = baseDelay * (1 << retryCount); // 1s, 2s, 4s...
    final capped = exponential > maxDelay ? maxDelay : exponential;
    // Add jitter (±25%)
    final jitter = (capped.inMilliseconds * 0.25).round();
    return Duration(milliseconds: capped.inMilliseconds + jitter);
  }
}