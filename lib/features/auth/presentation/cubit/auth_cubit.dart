import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/auth/data/models/auth_response.dart';
import 'package:nutq/features/auth/data/models/login_request.dart';
import 'package:nutq/features/auth/data/models/register_request.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this._repo}) : super(const AuthState.initial());

  final AuthRepository _repo;

  Future<void> login(LoginRequest request) async {
    emit(const AuthState.loading());
    final result = await _repo.login(request);
    _emitFromResult(result);
  }

  Future<void> register(RegisterRequest request) async {
    emit(const AuthState.loading());
    final result = await _repo.register(request);
    _emitFromResult(result);
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState.initial());
  }

  void _emitFromResult(ApiResult<AuthResponse> result) {
    result.when(
      success: (_) => emit(const AuthState.success()),
      failure: (error) => _emitFromError(error),
    );
  }

  void _emitFromError(ApiError error) {
    switch (error) {
      case ValidationError(:final fieldErrors):
        emit(AuthState.fieldErrors(fieldErrors));
      case NetworkError():
        emit(const AuthState.failure('No internet connection'));
      case TimeoutError():
        emit(const AuthState.failure('Request timed out'));
      case UnauthorizedError():
        emit(const AuthState.failure('Invalid credentials'));
      case ServerError(:final message):
        emit(AuthState.failure(message));
      case UnknownError(:final message):
        emit(AuthState.failure(message));
    }
  }
}
