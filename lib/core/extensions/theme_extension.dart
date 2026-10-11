import 'package:flutter/material.dart';
import 'package:nutq/core/theme/app_colors.dart';
import 'package:nutq/core/theme/app_typography.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// Instance facade over the static [AppTypography] scale, so styles can be read
/// from `context.typography.<getter>` (e.g. `context.typography.heading1`).
class AppTypographyRef {
  const AppTypographyRef();

  TextStyle get display => AppTypography.display;
  TextStyle get displayExtraBold => AppTypography.displayExtraBold;
  TextStyle get displayExtraBold2 => AppTypography.displayExtraBold2;

  TextStyle get heading1 => AppTypography.heading1;
  TextStyle get headingLarge => AppTypography.headingLarge;
  TextStyle get heading2 => AppTypography.heading2;
  TextStyle get heading3 => AppTypography.heading3;
  TextStyle get heading4 => AppTypography.heading4;
  TextStyle get heading5 => AppTypography.heading5;
  TextStyle get heading6 => AppTypography.heading6;
  TextStyle get heading7 => AppTypography.heading7;
  TextStyle get heading8 => AppTypography.heading8;
  TextStyle get heading9 => AppTypography.heading9;

  TextStyle get bodyXL => AppTypography.bodyXL;
  TextStyle get bodyLarge => AppTypography.bodyLarge;
  TextStyle get bodyBase => AppTypography.bodyBase;
  TextStyle get bodySmall => AppTypography.bodySmall;
  TextStyle get caption => AppTypography.caption;
  TextStyle get captionSmall => AppTypography.captionSmall;
  TextStyle get micro => AppTypography.micro;
  TextStyle get nano => AppTypography.nano;

  TextStyle get bodyMediumLarge => AppTypography.bodyMediumLarge;
  TextStyle get bodyMedium => AppTypography.bodyMedium;
  TextStyle get bodyMediumSmall => AppTypography.bodyMediumSmall;
  TextStyle get bodyMediumTiny => AppTypography.bodyMediumTiny;

  TextStyle get labelLarge => AppTypography.labelLarge;
  TextStyle get labelMedium => AppTypography.labelMedium;
  TextStyle get labelSmall => AppTypography.labelSmall;
  TextStyle get labelXS => AppTypography.labelXS;
  TextStyle get label2XS => AppTypography.label2XS;
  TextStyle get label => AppTypography.label;
  TextStyle get labelTiny => AppTypography.labelTiny;
  TextStyle get labelMicro => AppTypography.labelMicro;

  TextStyle get tag => AppTypography.tag;
}

extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colorsTheme => Theme.of(this).colorScheme;

  /// Full Nutq color-token set for the active theme (light/dark), named 1:1
  /// after the Figma Design System tokens (see [AppColors]).
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  /// Custom Nutq typography scale (see [AppTypographyRef]).
  AppTypographyRef get typography => const AppTypographyRef();

  /// Localized strings for the active locale (see [AppLocalizations]).
  AppLocalizations get l10n => AppLocalizations.of(this);
}
