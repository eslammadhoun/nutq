import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/dio/interceptors/auth_interceptor.dart';
import 'package:nutq/core/network/token/secure_token_storage.dart';
import 'package:nutq/core/network/token/token_refresher.dart';

/// Minimal in-memory TokenStorage.
class _FakeTokenStorage implements TokenStorage {
  String? access;
  String? refresh;
  var cleared = false;

  @override
  Future<String?> get accessToken async => access;

  @override
  Future<String?> get refreshToken async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    access = null;
    refresh = null;
  }

  @override
  Future<TokenPair?> get tokenPair async {
    final a = await accessToken;
    final r = await refreshToken;
    if (a != null && r != null) return TokenPair(accessToken: a, refreshToken: r);
    return null;
  }
}

/// Configurable TokenRefresher — the lambda decides success/rejection/transient.
class _FakeTokenRefresher implements TokenRefresher {
  _FakeTokenRefresher(this._behavior);

  final Future<TokenPair> Function(String refreshToken) _behavior;
  var calls = 0;

  @override
  Future<TokenPair> refresh(String refreshToken) {
    calls++;
    return _behavior(refreshToken);
  }
}

void main() {
  // NOTE: deliberately NO TestWidgetsFlutterBinding here — it intercepts all
  // HttpClient traffic and fakes 400 responses. These are pure-Dart tests
  // that talk to a real loopback HTTP server.
  late HttpServer server;
  late Dio dio;
  late _FakeTokenStorage storage;
  var expiredCount = 0;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    storage = _FakeTokenStorage()..access = 'old-access';
    storage.refresh = 'old-refresh';
    expiredCount = 0;
    dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:${server.port}'));
  });

  tearDown(() async {
    await server.close(force: true);
    dio.close();
  });

  void installInterceptor(TokenRefresher refresher) {
    final interceptor = AuthInterceptor(
      tokenStorage: storage,
      tokenRefresher: refresher,
      onSessionExpired: () async => expiredCount++,
    )..attach(dio);
    dio.interceptors.add(interceptor);
  }

  /// Serves [status]/[body] for the first request to [path], then [thenStatus]
  /// for subsequent ones (used for 401 → replay-200 sequences).
  void routeFirstThen(
    String path,
    int status,
    Object? body,
    int thenStatus,
    Object? thenBody,
  ) {
    var hits = 0;
    server.listen((req) async {
      if (req.uri.path == path) {
        final current = hits++;
        final respond = current == 0 ? (status, body) : (thenStatus, thenBody);
        await _respond(req, respond.$1, respond.$2);
        return;
      }
      await _respond(req, 404, {'detail': 'not found'});
    });
  }

  group('AuthInterceptor', () {
    test(
      'refreshes on 401, saves new tokens and replays the original request',
      () async {
        routeFirstThen('/jobs', 401, {'detail': 'expired'}, 200, [
          {'id': 'job-1'},
        ]);
        final refresher = _FakeTokenRefresher(
          (refreshToken) async {
            expect(refreshToken, 'old-refresh');
            return const TokenPair(
              accessToken: 'new-access',
              refreshToken: 'new-refresh',
            );
          },
        );
        expect(storage.access, isNotNull); // pre-seeded
        installInterceptor(refresher);

        final response = await dio.get('/jobs');

        expect(response.statusCode, 200);
        expect(refresher.calls, 1);
        expect(storage.access, 'new-access');
        expect(storage.refresh, 'new-refresh');
        expect(expiredCount, 0);
      },
    );

    test(
      'expires the session when refresh endpoint rejects with 401',
      () async {
        routeFirstThen('/jobs', 401, {'detail': 'expired'}, 200, []);
        final refresher = _FakeTokenRefresher((_) async {
          throw TokenRefreshRejectedException(
            DioException(
              requestOptions: RequestOptions(path: '/auth/refresh'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/auth/refresh'),
                statusCode: 401,
              ),
            ),
          );
        });
        installInterceptor(refresher);

        await expectLater(dio.get('/jobs'), throwsA(isA<DioException>()));

        expect(refresher.calls, 1);
        expect(expiredCount, 1);
        expect(storage.cleared, isTrue);
        expect(storage.access, isNull);
        expect(storage.refresh, isNull);
      },
    );

    test(
      'transient refresh failure keeps tokens and does NOT expire session',
      () async {
        routeFirstThen('/jobs', 401, {'detail': 'expired'}, 200, []);
        final refresher = _FakeTokenRefresher((_) async {
          throw DioException(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            type: DioExceptionType.connectionTimeout,
            message: 'offline',
          );
        });
        installInterceptor(refresher);

        await expectLater(dio.get('/jobs'), throwsA(isA<DioException>()));

        expect(refresher.calls, 1);
        expect(expiredCount, 0); // ← the M2 regression guard
        expect(storage.cleared, isFalse);
        expect(storage.access, 'old-access'); // tokens intact
        expect(storage.refresh, 'old-refresh');
      },
    );

    test('does not attempt refresh when no refresh token exists', () async {
      routeFirstThen('/jobs', 401, {'detail': 'expired'}, 200, []);
      storage.refresh = null;
      final refresher = _FakeTokenRefresher(
        (_) => throw StateError('must not be called'),
      );
      installInterceptor(refresher);

      await expectLater(dio.get('/jobs'), throwsA(isA<DioException>()));

      expect(refresher.calls, 0);
      expect(expiredCount, 1);
    });

    test('never refreshes on public endpoints (bad login)', () async {
      routeFirstThen('/auth/login', 401, {'detail': 'invalid credentials'}, 401,
          {});
      final refresher = _FakeTokenRefresher(
        (_) => throw StateError('must not be called'),
      );
      installInterceptor(refresher);

      await expectLater(
        dio.post(
          '/auth/login',
          data: {'email': 'a@b.c', 'password': 'wrong'},
          options: Options(extra: {'requiresAuth': false}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(refresher.calls, 0);
      expect(expiredCount, 0);
    });
  });
}

Future<void> _respond(HttpRequest req, int status, Object? body) async {
  req.response.statusCode = status;
  req.response.headers.contentType = ContentType.json;
  req.response.write(jsonEncode(body ?? {}));
  await req.response.close();
}
