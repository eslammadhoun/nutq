import 'package:flutter/material.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_typography.dart';

/// Nutq themes, built from the Figma Design System tokens (`Nutq _ Colors 2`).
///
/// Each theme carries its full 34-color token set via `ThemeData.extensions`
/// as an [AppColors] instance, resolved in widgets with
/// `context.appColors.<token>`. The built-in [ColorScheme] is mapped from
/// those same tokens so Material widgets also pick up the palette.
class AppTheme {
  static const BoxDecoration lightBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xffF8F9FB), Color(0xffFAFBFC), Color(0xFFFFFFFF)],
      stops: [0.0, 0.6, 1.0],
    ),
  );

  static const BoxDecoration darkBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff0B1120), Color(0xff111827), Color(0xff0F172A)],
      stops: [0.0, 0.6, 1.0],
    ),
  );

  static BoxDecoration backgroundDecoration(bool isDark) {
    return isDark ? darkBackgroundDecoration : lightBackgroundDecoration;
  }

  // ── Light ───────────────────────────────────────────────────────────────
  static ThemeData get light => _base(
    colors: AppColors.light,
    scheme: ColorScheme.light(
      primary: AppColors.light.primary,
      onPrimary: AppColors.light.textInverse,
      secondary: AppColors.light.primaryDark,
      onSecondary: AppColors.light.textInverse,
      error: AppColors.light.statusFailed,
      onError: AppColors.light.textInverse,
      surface: AppColors.light.surface,
      onSurface: AppColors.light.textPrimary,
      onSurfaceVariant: AppColors.light.textSecondary,
      surfaceContainerHighest: AppColors.light.subtle,
      outline: AppColors.light.borderDefault,
      outlineVariant: AppColors.light.borderSubtle,
    ),
  );

  // ── Dark ────────────────────────────────────────────────────────────────
  static ThemeData get dark => _base(
    colors: AppColors.dark,
    scheme: ColorScheme.dark(
      primary: AppColors.dark.primary,
      onPrimary: AppColors.dark.base,
      secondary: AppColors.dark.primaryDark,
      onSecondary: AppColors.dark.base,
      error: AppColors.dark.statusFailed,
      onError: AppColors.dark.textInverse,
      surface: AppColors.dark.surface,
      onSurface: AppColors.dark.textPrimary,
      onSurfaceVariant: AppColors.dark.textSecondary,
      surfaceContainerHighest: AppColors.dark.card,
      outline: AppColors.dark.borderDefault,
      outlineVariant: AppColors.dark.borderSubtle,
    ),
  );

  // ── Shared builder ──────────────────────────────────────────────────────
  static ThemeData _base({
    required AppColors colors,
    required ColorScheme scheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [colors],
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
    );
  }
}
