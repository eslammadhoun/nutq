part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success() = AuthSuccess;
  const factory AuthState.fieldErrors(Map<String, String> errors) =
      AuthFieldErrors;

  /// Carries the raw [ApiError] so the UI can localize it via
  /// `context.l10n.authErrorMessage(error)` — cubits have no BuildContext.
  const factory AuthState.failure(ApiError error) = AuthFailure;
}
