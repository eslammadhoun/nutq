import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
  ColorScheme get colorsTheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
