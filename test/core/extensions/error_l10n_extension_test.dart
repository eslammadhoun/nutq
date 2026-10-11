import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  test('every AppError has a localized message in both languages', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    for (final error in AppError.values) {
      expect(en.errorMessage(error), isNotEmpty, reason: '$error (en)');
      expect(ar.errorMessage(error), isNotEmpty, reason: '$error (ar)');
      expect(ar.errorMessage(error), isNot(en.errorMessage(error)), reason: '$error is translated');
    }
  });
}
