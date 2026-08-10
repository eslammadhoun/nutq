import 'package:dio/dio.dart';

class ErrorHandler {
  ErrorHandler._();

  static String handle(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map) {
            return (data['detail'] ?? data['message'] ?? 'Server error')
                .toString();
          }
          return 'Server error (${error.response?.statusCode})';
        default:
          return 'Unexpected error. Please try again.';
      }
    }
    return error.toString();
  }

  static int? statusCode(Object error) {
    if (error is DioException) return error.response?.statusCode;
    return null;
  }
}
