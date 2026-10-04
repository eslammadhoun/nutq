import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/l10n/app_localizations.dart';

extension AppErrorL10n on AppLocalizations {
  /// User-facing message for an [AppError] surfaced by a cubit.
  String errorMessage(AppError error) => switch (error) {
    AppError.storage => errorStorage,
  };
}
