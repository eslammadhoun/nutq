import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/core/network/token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/auth/data/datasources/auth_api_service.dart';
import 'package:nutq/features/auth/data/models/auth_models.dart';
import 'package:nutq/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthApiService extends Mock implements AuthApiService {}

class MockAppPreferences extends Mock implements AppPreferences {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthApiService api;
  late MockAppPreferences prefs;
  late MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    api = MockAuthApiService();
    prefs = MockAppPreferences();
    tokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(api, prefs, tokenStorage);

    registerFallbackValue(
      RegisterRequest(email: 'fallback@test.com', password: 'fallback'),
    );
    registerFallbackValue(
      LoginRequest(email: 'fallback@test.com', password: 'fallback'),
    );
  });

  group('register', () {
    test('returns success with the created user on a 2xx response', () async {
      final user = UserResponse(
        id: '1',
        email: 'a@test.com',
        createdAt: '2026-01-01T00:00:00Z',
      );
      when(() => api.register(any())).thenAnswer((_) async => user);

      final result = await repository.register('a@test.com', 'password123');

      expect(result, ApiResult<UserResponse>.success(user));
    });

    test('returns failure with the mapped message on a DioException', () async {
      when(() => api.register(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/register'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.register('a@test.com', 'password123');

      expect(
        result,
        const ApiResult<UserResponse>.failure('No internet connection.'),
      );
    });
  });

  group('login', () {
    final tokens = TokenResponse(
      accessToken: 'access-123',
      refreshToken: 'refresh-456',
      tokenType: 'bearer',
    );

    test('persists tokens and login flag on success', () async {
      when(() => api.login(any())).thenAnswer((_) async => tokens);
      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(() => prefs.setLoggedIn(true)).thenAnswer((_) async {});

      final result = await repository.login('a@test.com', 'password123');

      expect(result, ApiResult<TokenResponse>.success(tokens));
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
        ),
      ).called(1);
      verify(() => prefs.setLoggedIn(true)).called(1);
    });

    test('does not persist anything on failure', () async {
      when(() => api.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: {'detail': 'Invalid credentials'},
          ),
        ),
      );

      final result = await repository.login('a@test.com', 'wrong-password');

      expect(
        result,
        const ApiResult<TokenResponse>.failure(
          'Invalid credentials',
          statusCode: 401,
        ),
      );
      verifyNever(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
      verifyNever(() => prefs.setLoggedIn(any()));
    });
  });

  group('logout', () {
    test('clears tokens and the login flag', () async {
      when(() => tokenStorage.clear()).thenAnswer((_) async {});
      when(() => prefs.setLoggedIn(false)).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokenStorage.clear()).called(1);
      verify(() => prefs.setLoggedIn(false)).called(1);
    });
  });
}
