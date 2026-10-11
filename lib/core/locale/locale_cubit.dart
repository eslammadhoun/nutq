import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/preferences/app_preferences.dart';

const supportedLocales = [Locale('en'), Locale('ar')];

/// Holds the app's active locale and persists the user's explicit choice.
/// A null state means "no explicit choice" — Flutter falls back to the
/// device locale (restricted to [supportedLocales]).
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs)
    : super(
        _prefs.languageCode != null ? Locale(_prefs.languageCode!) : null,
      );

  final AppPreferences _prefs;

  Future<void> setLocale(Locale locale) async {
    await _prefs.setLanguageCode(locale.languageCode);
    emit(locale);
  }
}
