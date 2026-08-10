import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/auth/data/models/auth_models.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutq/features/auth/presentation/cubit/auth_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, success] when registration succeeds',
      build: () => AuthCubit(repository),
      setUp: () {
        when(() => repository.register(any(), any())).thenAnswer(
          (_) async => const ApiResult.success(
            UserResponse(id: '1', email: 'a@test.com', createdAt: 'now'),
          ),
        );
      },
      act: (cubit) => cubit.register('a@test.com', 'password123'),
      expect: () => [
        const AuthLoading(),
        const AuthSuccess('Account created. Please log in.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when registration fails',
      build: () => AuthCubit(repository),
      setUp: () {
        when(() => repository.register(any(), any())).thenAnswer(
          (_) async => const ApiResult.failure('Email already registered'),
        );
      },
      act: (cubit) => cubit.register('a@test.com', 'password123'),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email already registered'),
      ],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, success] when login succeeds',
      build: () => AuthCubit(repository),
      setUp: () {
        when(() => repository.login(any(), any())).thenAnswer(
          (_) async => const ApiResult.success(
            TokenResponse(
              accessToken: 'access',
              refreshToken: 'refresh',
              tokenType: 'bearer',
            ),
          ),
        );
      },
      act: (cubit) => cubit.login('a@test.com', 'password123'),
      expect: () => [const AuthLoading(), const AuthSuccess('Logged in')],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when login fails',
      build: () => AuthCubit(repository),
      setUp: () {
        when(() => repository.login(any(), any())).thenAnswer(
          (_) async =>
              const ApiResult.failure('Invalid credentials', statusCode: 401),
        );
      },
      act: (cubit) => cubit.login('a@test.com', 'wrong-password'),
      expect: () => [const AuthLoading(), const AuthError('Invalid credentials')],
    );
  });
}
