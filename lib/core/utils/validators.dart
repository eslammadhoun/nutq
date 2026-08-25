import 'package:nutq/l10n/app_localizations.dart';

class Validators {
  /// Unicode letters (incl. Arabic), spaces, hyphens, straight/curly
  /// apostrophes — iOS autocorrect often replaces ' with ’.
  static final _namePattern = RegExp(r"^[\p{L}\s\-''’]+$", unicode: true);

  static String? validateName(String? value, AppLocalizations l10n) =>
      _validate(
        value,
        l10n,
        field: l10n.registerUsernameLabel,
        minLength: 2,
        maxLength: 50,
        extra: (v) => _namePattern.hasMatch(v)
            ? null
            : l10n.validationNameChars,
      );

  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.validationFieldRequired(l10n.authEmailLabel);
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&\*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    if (!emailRegex.hasMatch(value)) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  static String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.validationFieldRequired(l10n.authPasswordLabel);
    }
    if (value.length < 8) {
      return l10n.validationMinLength(l10n.authPasswordLabel, 8);
    }
    if (value.length > 128) {
      return l10n.validationMaxLength(l10n.authPasswordLabel, 128);
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return l10n.validationPasswordLowercase;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.validationPasswordUppercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.validationPasswordNumber;
    }
    return null;
  }

  static String? validateUsername(String? value, AppLocalizations l10n) =>
      _validate(
        value,
        l10n,
        field: l10n.registerUsernameLabel,
        minLength: 3,
        maxLength: 30,
        extra: (v) => RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(v)
            ? null
            : l10n.validationUsernameChars,
      );

  static String? validateConfirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) {
      return l10n.validationFieldRequired(l10n.registerConfirmPasswordLabel);
    }
    if (value != password) {
      return l10n.validationPasswordsMismatch;
    }
    return null;
  }

  static String? _validate(
    String? value,
    AppLocalizations l10n, {
    required String field,
    required int minLength,
    required int maxLength,
    String? Function(String value)? extra,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationFieldRequired(field);
    }
    if (value.length < minLength) {
      return l10n.validationMinLength(field, minLength);
    }
    if (value.length > maxLength) {
      return l10n.validationMaxLength(field, maxLength);
    }
    final extraError = extra?.call(value);
    if (extraError != null) return extraError;
    return null;
  }
}
