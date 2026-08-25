import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/utils/validators.dart';
import 'package:nutq/l10n/app_localizations.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations ar;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    ar = await AppLocalizations.delegate.load(const Locale('ar'));
  });

  group('Validators.validateName', () {
    test('accepts Arabic names', () {
      expect(Validators.validateName('أحمد', en), isNull);
      expect(Validators.validateName('محمد عبد الله', en), isNull);
      expect(Validators.validateName('نور الهدى', en), isNull);
    });

    test('accepts Latin names with hyphens and apostrophes', () {
      expect(Validators.validateName('O\'Brien', en), isNull);
      expect(Validators.validateName('Mary-Jane', en), isNull);
      expect(Validators.validateName('Ahmed', en), isNull);
    });

    test('accepts curly apostrophe from iOS autocorrect', () {
      expect(Validators.validateName('O’Brien', en), isNull);
    });

    test('rejects digits and symbols', () {
      expect(Validators.validateName('Ahmed1', en), isNotNull);
      expect(Validators.validateName('a<b>', en), isNotNull);
    });

    test('rejects empty and whitespace-only values', () {
      expect(Validators.validateName(null, en), isNotNull);
      expect(Validators.validateName('', en), isNotNull);
      expect(Validators.validateName('   ', en), isNotNull);
    });

    test('enforces length bounds', () {
      expect(Validators.validateName('أ', en), isNotNull);
      expect(Validators.validateName('ا' * 51, en), isNotNull);
      expect(Validators.validateName('ا' * 50, en), isNull);
    });

    test('messages are localized (EN vs AR)', () {
      final enMessage = Validators.validateName('Ahmed1', en);
      final arMessage = Validators.validateName('أحمد1', ar);

      expect(enMessage, en.validationNameChars);
      expect(arMessage, isNot(enMessage));
      expect(arMessage, contains('الاسم'));
    });
  });

  group('Validators.validateEmail', () {
    test('accepts valid emails', () {
      expect(Validators.validateEmail('user@example.com', en), isNull);
      expect(
        Validators.validateEmail('user+tag@sub.example.com', en),
        isNull,
      );
    });

    test('rejects invalid emails with localized message', () {
      expect(
        Validators.validateEmail('no-at-sign', en),
        en.validationEmailInvalid,
      );
      expect(Validators.validateEmail('@example.com', en), isNotNull);
      expect(Validators.validateEmail('', en), isNotNull);
      expect(Validators.validateEmail(null, en), isNotNull);
    });
  });

  group('Validators.validatePassword', () {
    test('accepts strong passwords', () {
      expect(Validators.validatePassword('Sup3rSecret', en), isNull);
    });

    test('rejects weak passwords', () {
      expect(Validators.validatePassword('short1A', en), isNotNull); // < 8
      expect(
        Validators.validatePassword('alllowercase1', en),
        en.validationPasswordUppercase,
      );
      expect(
        Validators.validatePassword('ALLUPPERCASE1', en),
        en.validationPasswordLowercase,
      );
      expect(
        Validators.validatePassword('NoDigitsHere', en),
        en.validationPasswordNumber,
      );
    });

    test('required/length messages use localized field label', () {
      expect(
        Validators.validatePassword('', en),
        en.validationFieldRequired(en.authPasswordLabel),
      );
      expect(
        Validators.validatePassword('Ab1', en),
        en.validationMinLength(en.authPasswordLabel, 8),
      );
    });
  });

  group('Validators.validateConfirmPassword', () {
    test('mismatch is localized', () {
      expect(
        Validators.validateConfirmPassword('aaa', 'bbb', en),
        en.validationPasswordsMismatch,
      );
      expect(Validators.validateConfirmPassword('abc', 'abc', en), isNull);
    });
  });
}
