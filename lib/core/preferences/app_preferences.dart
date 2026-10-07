import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keySeenOnboarding = 'has_seen_onboarding';
  static const _keyLanguageCode = 'language_code';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAlertsSeenAt = 'alerts_seen_at';
  static const _keyAlertsDismissed = 'alerts_dismissed';
  static const _keyNotifyWhenDone = 'notify_when_done';

  /// SRS 4.1: onboarding is shown only on first launch.
  bool get hasSeenOnboarding => _prefs.getBool(_keySeenOnboarding) ?? false;

  Future<void> setSeenOnboarding() => _prefs.setBool(_keySeenOnboarding, true);

  /// null means "no explicit choice yet" — fall back to device locale.
  String? get languageCode => _prefs.getString(_keyLanguageCode);

  Future<void> setLanguageCode(String code) => _prefs.setString(_keyLanguageCode, code);

  /// `system`, `light` or `dark`; null until the user picks one.
  String? get themeMode => _prefs.getString(_keyThemeMode);

  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  /// When the user last looked at Alerts; alerts after it are unread.
  DateTime? get alertsSeenAt {
    final ms = _prefs.getInt(_keyAlertsSeenAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> setAlertsSeenAt(DateTime at) =>
      _prefs.setInt(_keyAlertsSeenAt, at.toUtc().millisecondsSinceEpoch);

  /// Job ids whose alerts the user dismissed.
  Set<String> get alertsDismissed =>
      (_prefs.getStringList(_keyAlertsDismissed) ?? const []).toSet();

  Future<void> setAlertsDismissed(Set<String> ids) =>
      _prefs.setStringList(_keyAlertsDismissed, ids.toList());

  /// Whether a job that finishes outside the app posts "Summary ready". On
  /// until the user turns it off in Settings.
  bool get notifyWhenDone => _prefs.getBool(_keyNotifyWhenDone) ?? true;

  Future<void> setNotifyWhenDone(bool value) => _prefs.setBool(_keyNotifyWhenDone, value);
}
