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

  group('ApiErrorL10n.jobsErrorMessage', () {
    test('maps network/timeout/server-unreachable to localized strings', () {
      expect(en.jobsErrorMessage(const ApiError.network()), en.errorNoConnection);
      expect(
        en.jobsErrorMessage(const ApiError.serverUnreachable()),
        en.errorServerUnreachable,
      );
      expect(en.jobsErrorMessage(const ApiError.timeout()), en.errorTimeout);
    });

    test('server/unknown messages pass through, empty falls back', () {
      expect(
        en.jobsErrorMessage(const ApiError.server('Quota exceeded', 503)),
        'Quota exceeded',
      );
      expect(
        en.jobsErrorMessage(const ApiError.unknown('')),
        en.somethingWentWrong,
      );
    });

    test('validation uses first field error when present', () {
      expect(
        en.jobsErrorMessage(
          const ApiError.validation({'email': 'Email taken'}),
        ),
        'Email taken',
      );
      expect(
        en.jobsErrorMessage(const ApiError.validation({})),
        en.somethingWentWrong,
      );
    });

    test('maps the local-processing error variants to localized strings', () {
      expect(
        en.jobsErrorMessage(const ApiError.modelNotDownloaded('whisper-base')),
        en.errorModelNotDownloaded,
      );
      expect(
        en.jobsErrorMessage(const ApiError.insufficientStorage()),
        en.errorInsufficientStorage,
      );
      expect(
        en.jobsErrorMessage(const ApiError.insufficientMemory()),
        en.errorInsufficientMemory,
      );
      expect(
        en.jobsErrorMessage(const ApiError.processingCancelled()),
        en.errorProcessingCancelled,
      );
      expect(
        en.jobsErrorMessage(const ApiError.audioDecodeFailed('bad header')),
        en.errorAudioDecodeFailed,
      );
      expect(
        en.jobsErrorMessage(const ApiError.nativeEngineFailure('crash')),
        en.errorNativeEngineFailure,
      );
      expect(
        en.jobsErrorMessage(const ApiError.deviceOffline()),
        en.errorDeviceOffline,
      );
    });

    test('Arabic locale returns Arabic copy', () {
      expect(ar.jobsErrorMessage(const ApiError.network()), contains('الإنترنت'));
    });
  });
}
