import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1A56DB);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _primaryColor,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      );
}
