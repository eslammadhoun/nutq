import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keySeenOnboarding = 'has_seen_onboarding';
  static const _keyLanguageCode = 'language_code';

  /// SRS 4.1: onboarding is shown only on first launch.
  bool get hasSeenOnboarding => _prefs.getBool(_keySeenOnboarding) ?? false;

  Future<void> setSeenOnboarding() => _prefs.setBool(_keySeenOnboarding, true);

  /// null means "no explicit choice yet" — fall back to device locale.
  String? get languageCode => _prefs.getString(_keyLanguageCode);

  Future<void> setLanguageCode(String code) => _prefs.setString(_keyLanguageCode, code);
}
