import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/auth/domain/params/login_params.dart';
import 'package:nutq/features/auth/domain/params/register_params.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this._repo}) : super(const AuthState.initial());

  final AuthRepository _repo;

  Future<void> login(LoginParams params) async {
    emit(const AuthState.loading());
    final result = await _repo.login(params);
    _emitFromResult(result);
  }

  Future<void> register(RegisterParams params) async {
    emit(const AuthState.loading());
    final result = await _repo.register(params);
    _emitFromResult(result);
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState.initial());
  }

  void _emitFromResult(ApiResult<void> result) {
    result.when(
      success: (_) => emit(const AuthState.success()),
      failure: (error) => _emitFromError(error),
    );
  }

  void _emitFromError(ApiError error) {
    switch (error) {
      case ValidationError(:final fieldErrors):
        emit(AuthState.fieldErrors(fieldErrors));
      default:
        // Raw error travels to the UI, which localizes it at display time.
        emit(AuthState.failure(error));
    }
  }
}
