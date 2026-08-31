import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/error/error_handler.dart';

DioException _badResponse(Object? body, int status) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: body,
  ),
);

void main() {
  group('ErrorHandler non-JSON error bodies (regression)', () {
    test('plain-string body does not throw', () {
      final error = ErrorHandler.map(_badResponse('Internal Server Error', 502));
      expect(error, isA<ServerError>());
      expect((error as ServerError).message, 'Internal Server Error');
    });

    test('list body does not throw, falls back to default message', () {
      final error = ErrorHandler.map(_badResponse(['a', 'b'], 503));
      expect(error, isA<ServerError>());
      expect((error as ServerError).message, 'Server error');
    });

    test('null body falls back to default message', () {
      final error = ErrorHandler.map(_badResponse(null, 500));
      expect((error as ServerError).message, 'Server error');
    });
  });

  group('ErrorHandler JSON bodies still work', () {
    test('FastAPI detail string is extracted', () {
      final error = ErrorHandler.map(_badResponse({'detail': 'boom'}, 500));
      expect((error as ServerError).message, 'boom');
    });

    test('422 field errors map to ValidationError', () {
      final error = ErrorHandler.map(
        _badResponse({
          'detail': [
            {
              'loc': ['body', 'email'],
              'msg': 'invalid email',
            },
          ],
        }, 422),
      );
      expect(error, isA<ValidationError>());
    });

    test('timeout and connection types map correctly', () {
      expect(
        ErrorHandler.map(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isA<TimeoutError>(),
      );
      expect(
        ErrorHandler.map(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionError,
          ),
        ),
        isA<NetworkError>(),
      );
    });
  });
}
