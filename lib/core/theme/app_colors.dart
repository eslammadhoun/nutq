import 'package:flutter/material.dart';

/// Nutq color tokens, mode-paired (light/dark), sourced 1:1 from the Figma
/// design system export (`Nutq _ Colors 2/Light.tokens.json` and
/// `Nutq _ Colors 2/Dark.tokens.json`).
///
/// Field names map 1:1 to the token files (dot/kebab-case converted to
/// camelCase), so a token such as `bg.page` → `AppColors.page`. Each token
/// carries a light and a dark value and is resolved from the active theme:
///
/// ```dart
/// context.appColors.primary      // #1A56DB light · #4F83F1 dark
/// context.appColors.statusFailed  // #DC2626 light · #F87171 dark
/// ```
///
/// Registered in [ThemeData] via `ThemeData.extensions`, so it switches
/// automatically with `ThemeMode.system` alongside the built-in [ColorScheme].
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  // ── brand ────────────────────────────────────────────────────────────────
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryLighter;
  final Color primary300;

  // ── bg ───────────────────────────────────────────────────────────────────
  final Color base;
  final Color surface;
  final Color card;
  final Color subtle;
  final Color page;
  final Color overlay;

  // ── text ─────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textBrand;
  final Color textInverse;
  final Color textMuted;
  final Color textTertiary;

  // ── border ───────────────────────────────────────────────────────────────
  final Color borderSubtle;
  final Color borderDefault;

  // ── status ───────────────────────────────────────────────────────────────
  final Color statusDone;
  final Color statusDoneBg;
  final Color statusProcessing;
  final Color statusProcessingBg;
  final Color statusQueued;
  final Color statusQueuedBg;
  final Color statusFailed;
  final Color statusFailedBg;
  final Color statusCancelled;
  final Color statusCancelledBg;
  final Color statusWarning;
  final Color statusWarningBg;

  // ── nav ──────────────────────────────────────────────────────────────────
  final Color navBarBg;
  final Color navIndicator;

  // ── scrim ────────────────────────────────────────────────────────────────
  final Color scrimOverlay;

  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryLighter,
    required this.primary300,
    required this.base,
    required this.surface,
    required this.card,
    required this.subtle,
    required this.page,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textBrand,
    required this.textInverse,
    required this.textMuted,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderDefault,
    required this.statusDone,
    required this.statusDoneBg,
    required this.statusProcessing,
    required this.statusProcessingBg,
    required this.statusQueued,
    required this.statusQueuedBg,
    required this.statusFailed,
    required this.statusFailedBg,
    required this.statusCancelled,
    required this.statusCancelledBg,
    required this.statusWarning,
    required this.statusWarningBg,
    required this.navBarBg,
    required this.navIndicator,
    required this.scrimOverlay,
  });

  /// Light-mode token values (`com.figma.modeName: "Light"`).
  static const AppColors light = AppColors(
    primary: Color(0xFF1A56DB),
    primaryDark: Color(0xFF1648C0),
    primaryLight: Color(0xFFEBF1FF),
    primaryLighter: Color(0xFFEBF5FF),
    primary300: Color(0xFF76A9FA),
    base: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    card: Color(0xFFFFFFFF),
    subtle: Color(0xFFF3F4F6),
    page: Color(0xFFF8FAFC),
    overlay: Color(0xFF11182A),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textBrand: Color(0xFF1A56DB),
    textInverse: Color(0xFFFFFFFF),
    textMuted: Color(0xFF9CA3AF),
    textTertiary: Color(0xFF374151),
    borderSubtle: Color(0xFFE2E8F0),
    borderDefault: Color(0xFFE5E7EB),
    statusDone: Color(0xFF059669),
    statusDoneBg: Color(0xFFECFDF5),
    statusProcessing: Color(0xFF2563EB),
    statusProcessingBg: Color(0xFFEFF6FF),
    statusQueued: Color(0xFF64748B),
    statusQueuedBg: Color(0xFFF1F5F9),
    statusFailed: Color(0xFFDC2626),
    statusFailedBg: Color(0xFFFEF2F2),
    statusCancelled: Color(0xFF6B7280),
    statusCancelledBg: Color(0xFFF3F4F6),
    statusWarning: Color(0xFFC27803),
    statusWarningBg: Color(0xFFFDF3D3),
    navBarBg: Color(0xFFFFFFFF),
    navIndicator: Color(0xFF1A56DB),
    scrimOverlay: Color(0xFF11182A),
  );

  /// Dark-mode token values (`com.figma.modeName: "Dark"`).
  static const AppColors dark = AppColors(
    primary: Color(0xFF1A56DB),
    primaryDark: Color(0xFF76A9FA),
    primaryLight: Color(0xFF1E3A5F),
    primaryLighter: Color(0xFF0F2040),
    primary300: Color(0xFF93C5FD),
    base: Color(0xFF111928),
    surface: Color(0xFF1F2A37),
    card: Color(0xFF374151),
    subtle: Color(0xFF1F2A37),
    page: Color(0xFF0D1117),
    overlay: Color(0xFF000000),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF9CA3AF),
    textBrand: Color(0xFF76A9FA),
    textInverse: Color(0xFFFFFFFF),
    textMuted: Color(0xFF6B7280),
    textTertiary: Color(0xFF6B7280),
    borderSubtle: Color(0xFF1F2A37),
    borderDefault: Color(0xFF374151),
    statusDone: Color(0xFF34D399),
    statusDoneBg: Color(0xFF064E3B),
    statusProcessing: Color(0xFF60A5FA),
    statusProcessingBg: Color(0xFF1E3A5F),
    statusQueued: Color(0xFF9CA3AF),
    statusQueuedBg: Color(0xFF1F2A37),
    statusFailed: Color(0xFFF87171),
    statusFailedBg: Color(0xFF450A0A),
    statusCancelled: Color(0xFF6B7280),
    statusCancelledBg: Color(0xFF1F2A37),
    statusWarning: Color(0xFFFBBF24),
    statusWarningBg: Color(0xFF451A03),
    navBarBg: Color(0xFF1F2A37),
    navIndicator: Color(0xFF4F83F1),
    scrimOverlay: Color(0xFF000000),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primaryLighter,
    Color? primary300,
    Color? base,
    Color? surface,
    Color? card,
    Color? subtle,
    Color? page,
    Color? overlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textBrand,
    Color? textInverse,
    Color? textMuted,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderDefault,
    Color? statusDone,
    Color? statusDoneBg,
    Color? statusProcessing,
    Color? statusProcessingBg,
    Color? statusQueued,
    Color? statusQueuedBg,
    Color? statusFailed,
    Color? statusFailedBg,
    Color? statusCancelled,
    Color? statusCancelledBg,
    Color? statusWarning,
    Color? statusWarningBg,
    Color? navBarBg,
    Color? navIndicator,
    Color? scrimOverlay,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryLighter: primaryLighter ?? this.primaryLighter,
      primary300: primary300 ?? this.primary300,
      base: base ?? this.base,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      subtle: subtle ?? this.subtle,
      page: page ?? this.page,
      overlay: overlay ?? this.overlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textBrand: textBrand ?? this.textBrand,
      textInverse: textInverse ?? this.textInverse,
      textMuted: textMuted ?? this.textMuted,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      statusDone: statusDone ?? this.statusDone,
      statusDoneBg: statusDoneBg ?? this.statusDoneBg,
      statusProcessing: statusProcessing ?? this.statusProcessing,
      statusProcessingBg: statusProcessingBg ?? this.statusProcessingBg,
      statusQueued: statusQueued ?? this.statusQueued,
      statusQueuedBg: statusQueuedBg ?? this.statusQueuedBg,
      statusFailed: statusFailed ?? this.statusFailed,
      statusFailedBg: statusFailedBg ?? this.statusFailedBg,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      statusCancelledBg: statusCancelledBg ?? this.statusCancelledBg,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningBg: statusWarningBg ?? this.statusWarningBg,
      navBarBg: navBarBg ?? this.navBarBg,
      navIndicator: navIndicator ?? this.navIndicator,
      scrimOverlay: scrimOverlay ?? this.scrimOverlay,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryDark: l(primaryDark, other.primaryDark),
      primaryLight: l(primaryLight, other.primaryLight),
      primaryLighter: l(primaryLighter, other.primaryLighter),
      primary300: l(primary300, other.primary300),
      base: l(base, other.base),
      surface: l(surface, other.surface),
      card: l(card, other.card),
      subtle: l(subtle, other.subtle),
      page: l(page, other.page),
      overlay: l(overlay, other.overlay),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textBrand: l(textBrand, other.textBrand),
      textInverse: l(textInverse, other.textInverse),
      textMuted: l(textMuted, other.textMuted),
      textTertiary: l(textTertiary, other.textTertiary),
      borderSubtle: l(borderSubtle, other.borderSubtle),
      borderDefault: l(borderDefault, other.borderDefault),
      statusDone: l(statusDone, other.statusDone),
      statusDoneBg: l(statusDoneBg, other.statusDoneBg),
      statusProcessing: l(statusProcessing, other.statusProcessing),
      statusProcessingBg: l(statusProcessingBg, other.statusProcessingBg),
      statusQueued: l(statusQueued, other.statusQueued),
      statusQueuedBg: l(statusQueuedBg, other.statusQueuedBg),
      statusFailed: l(statusFailed, other.statusFailed),
      statusFailedBg: l(statusFailedBg, other.statusFailedBg),
      statusCancelled: l(statusCancelled, other.statusCancelled),
      statusCancelledBg: l(statusCancelledBg, other.statusCancelledBg),
      statusWarning: l(statusWarning, other.statusWarning),
      statusWarningBg: l(statusWarningBg, other.statusWarningBg),
      navBarBg: l(navBarBg, other.navBarBg),
      navIndicator: l(navIndicator, other.navIndicator),
      scrimOverlay: l(scrimOverlay, other.scrimOverlay),
    );
  }
}
