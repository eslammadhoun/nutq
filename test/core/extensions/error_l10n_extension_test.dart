import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations ar;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    ar = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  group('AuthErrorL10n.authErrorMessage', () {
    test('maps network/timeout/unauthorized to localized strings', () {
      expect(en.authErrorMessage(const ApiError.network()), en.errorNoConnection);
      expect(
        en.authErrorMessage(const ApiError.serverUnreachable()),
        en.errorServerUnreachable,
      );
      expect(en.authErrorMessage(const ApiError.timeout()), en.errorTimeout);
      expect(
        en.authErrorMessage(const ApiError.unauthorized()),
        en.errorInvalidCredentials,
      );
    });

    test('server/unknown messages pass through, empty falls back', () {
      expect(
        en.authErrorMessage(const ApiError.server('Quota exceeded', 503)),
        'Quota exceeded',
      );
      expect(
        en.authErrorMessage(const ApiError.unknown('')),
        en.somethingWentWrong,
      );
    });

    test('validation uses first field error when present', () {
      expect(
        en.authErrorMessage(
          const ApiError.validation({'email': 'Email taken'}),
        ),
        'Email taken',
      );
      expect(
        en.authErrorMessage(const ApiError.validation({})),
        en.somethingWentWrong,
      );
    });

    test('Arabic locale returns Arabic copy', () {
      expect(ar.authErrorMessage(const ApiError.network()), contains('الإنترنت'));
    });
  });

  group('AuthErrorL10n.jobsErrorMessage', () {
    test('unauthorized asks for re-login in a jobs context', () {
      expect(
        en.jobsErrorMessage(const ApiError.unauthorized()),
        en.errorLoginAgain,
      );
    });
  });
}
