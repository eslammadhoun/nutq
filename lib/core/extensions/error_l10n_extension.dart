import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/l10n/app_localizations.dart';

extension AuthErrorL10n on AppLocalizations {
  /// User-facing message for an auth failure. "Unauthorized" means bad
  /// credentials in an auth context.
  String authErrorMessage(ApiError error) =>
      _map(error, errorInvalidCredentials);

  /// User-facing message for a jobs failure. "Unauthorized" means the
  /// session died — ask for re-login.
  String jobsErrorMessage(ApiError error) => _map(error, errorLoginAgain);

  String _map(ApiError error, String unauthorizedMessage) => switch (error) {
    NetworkError() => errorNoConnection,
    TimeoutError() => errorTimeout,
    UnauthorizedError() => unauthorizedMessage,
    ValidationError(:final fieldErrors) =>
      fieldErrors.values.isNotEmpty ? fieldErrors.values.first : somethingWentWrong,
    ServerError(:final message) =>
      message.isEmpty ? somethingWentWrong : message,
    UnknownError(:final message) =>
      message.isEmpty ? somethingWentWrong : message,
  };
}
