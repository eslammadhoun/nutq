import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Debug-only structured logging via pretty_dio_logger
class LoggingInterceptor extends PrettyDioLogger {
  LoggingInterceptor()
    : super(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      );
}
