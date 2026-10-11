import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('follows the phone until a choice is made, then remembers it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    final cubit = ThemeCubit(prefs);
    expect(cubit.state, ThemeMode.system);

    await cubit.setThemeMode(ThemeMode.dark);
    expect(cubit.state, ThemeMode.dark);
    expect(ThemeCubit(prefs).state, ThemeMode.dark, reason: 'persisted');
    await cubit.close();
  });
}
