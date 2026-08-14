import 'package:flutter/material.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_typography.dart';

/// Nutq themes, built from the Figma Design System tokens (v1.0).
class AppTheme {
  static const BoxDecoration lightBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xffE8F0FE), Color(0xffF3F7FF), Color(0xFFFFFFFF)],
      stops: [0.0, 5, 1.0],
    ),
  );

  static const BoxDecoration darkBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff0B1120), Color(0xff111827), Color(0xff0F1729)],
      stops: [0.0, 0.6, 1.0],
    ),
  );

  static BoxDecoration backgroundDecoration(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkBackgroundDecoration
        : lightBackgroundDecoration;
  }

  // ── Light ───────────────────────────────────────────────────────────────
  static ThemeData get light => _base(
    const ColorScheme.light(
      primary: AppColors.primary500,
      onPrimary: Colors.white,
      secondary: AppColors.primary400,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerHighest: AppColors.grey100,
      outline: AppColors.grey200,
      outlineVariant: AppColors.grey100,
    ),
  );

  // ── Dark ────────────────────────────────────────────────────────────────
  // Per Figma dark screens: surfaces #1F2A37 on background #111928, primary
  // buttons keep #1A56DB, while text-level accents (links, focus) lighten to
  // primary300 (#76A9FA) for legibility.
  static ThemeData get dark => _base(
    const ColorScheme.dark(
      primary: AppColors.primary500,
      onPrimary: AppColors.grey900,
      secondary: AppColors.primary300,
      onSecondary: AppColors.grey900,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerHighest: AppColors.darkSurfaceRaised,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkSurfaceRaised,
    ),
  );

  // ── Shared builder ──────────────────────────────────────────────────────
  static ThemeData _base(ColorScheme scheme) {
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: textTheme,
    );
  }
}
