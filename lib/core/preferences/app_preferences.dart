import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLoggedIn = 'is_logged_in';

  bool get isLoggedIn => _prefs.getBool(_keyLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(_keyLoggedIn, value);
}
