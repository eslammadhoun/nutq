import 'dart:developer' as dev;
import 'package:dio/dio.dart';

/// Debug-only structured logging
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({void Function(Object, {String? name})? logPrint})
    : _logPrint = logPrint ?? _defaultLog;

  static void _defaultLog(Object message, {String? name}) {
    dev.log(message.toString(), name: name ?? 'Dio');
  }

  final void Function(Object, {String? name}) _logPrint;

  void _log(Object message, {String? name}) {
    _logPrint(message, name: name);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log(
      '→ ${options.method} ${options.uri}',
      name: 'Dio',
    );
    if (options.data != null) {
      _log(' Body: ${options.data}', name: 'Dio');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'Dio',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✗ ${err.response?.statusCode ?? err.type} ${err.requestOptions.uri} — ${err.message}',
      name: 'Dio',
    );
    handler.next(err);
  }
}