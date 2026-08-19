part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success() = AuthSuccess;
  const factory AuthState.fieldErrors(Map<String, String> errors) =
      AuthFieldErrors;
  const factory AuthState.failure(String message) = AuthFailure;
}
