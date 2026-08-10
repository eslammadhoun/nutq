import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/network/api_result.dart';
import 'package:nutq/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepository _repo;

  Future<void> register(String email, String password) async {
    emit(const AuthLoading());
    final result = await _repo.register(email, password);
    switch (result) {
      case Success():
        emit(const AuthSuccess('Account created. Please log in.'));
      case Failure(:final message):
        emit(AuthError(message));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await _repo.login(email, password);
    switch (result) {
      case Success():
        emit(const AuthSuccess('Logged in'));
      case Failure(:final message):
        emit(AuthError(message));
    }
  }
}
