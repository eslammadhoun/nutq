import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/dio/interceptors/retry_interceptor.dart';

void main() {
  // NOTE: deliberately NO TestWidgetsFlutterBinding here — it intercepts all
  // HttpClient traffic and fakes 400 responses. These are pure-Dart tests
  // that talk to a real loopback HTTP server.
  late HttpServer server;
  late Dio dio;
  var requestsReceived = 0;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    requestsReceived = 0;
    server.listen((req) async {
      requestsReceived++;
      req.response.statusCode = 500; // always fail → retryable
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode({'detail': 'boom'}));
      await req.response.close();
    });
    dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'));
    dio.interceptors.add(
      // Tiny delays so tests stay fast.
      RetryInterceptor(
        maxRetries: 3,
        baseDelay: const Duration(milliseconds: 1),
        maxDelay: const Duration(milliseconds: 4),
      )..attach(dio),
    );
  });

  tearDown(() async {
    await server.close(force: true);
    dio.close();
  });

  group('RetryInterceptor', () {
    test('retries idempotent GET up to maxRetries on 5xx', () async {
      await expectLater(dio.get('/jobs'), throwsA(isA<DioException>()));

      // 1 original + 3 retries
      expect(requestsReceived, 4);
    });

    test('never retries POST (non-idempotent)', () async {
      await expectLater(
        dio.post('/jobs', data: {'url': 'https://example.com/a.mp3'}),
        throwsA(isA<DioException>()),
      );

      expect(requestsReceived, 1);
    });

    test('never retries PUT (non-idempotent)', () async {
      await expectLater(
        dio.put('/jobs/1', data: {'x': 1}),
        throwsA(isA<DioException>()),
      );

      expect(requestsReceived, 1);
    });
  });
}
