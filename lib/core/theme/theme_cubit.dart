import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/preferences/app_preferences.dart';

/// The app's light/dark choice, persisted. Follows the phone until the user
/// picks one.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_parse(_prefs.themeMode));

  final AppPreferences _prefs;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode.name);
    emit(mode);
  }

  static ThemeMode _parse(String? name) =>
      ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);
}
