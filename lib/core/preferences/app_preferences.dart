import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLoggedIn = 'is_logged_in';
  static const _keySeenOnboarding = 'has_seen_onboarding';

  bool get isLoggedIn => _prefs.getBool(_keyLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(_keyLoggedIn, value);

  /// SRS 4.1: onboarding is shown only on first launch.
  bool get hasSeenOnboarding => _prefs.getBool(_keySeenOnboarding) ?? false;

  Future<void> setSeenOnboarding() =>
      _prefs.setBool(_keySeenOnboarding, true);
}
