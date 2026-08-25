import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// Nutq typography scale, mirrored from the Figma Design System text styles
/// (`Nutq/Display/…`, `Nutq/Heading/…`, `Nutq/Label/…`, `Nutq/Body/…`).
///
/// Inter for Latin UI; Noto Sans Arabic is the Arabic fallback. All sizes scale
/// with ScreenUtil (`.sp`); `height` is derived from Figma `line-height / size`.
/// Tracking is 0 for every style (the design's variable tokens carry no letter
/// spacing), so `letterSpacing` is omitted.

final class AppTypography {
  static const String fontFamily = 'Inter';

  static const List<String> fontFamilyFallback = ['NotoSansArabic'];

  static TextStyle _s({
    required double size,
    required double lineHeight,
    required FontWeight weight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: size.sp,
      height: lineHeight / size,
      fontWeight: weight,
    );
  }

  // ── Display (Inter 800) ────────────────────────────────────────────────────
  /// `Nutq/Display` — hero / splash headlines.
  static TextStyle get display =>
      _s(size: 44, lineHeight: 52, weight: FontWeight.w800);

  /// `Nutq/Display/ExtraBold` — hero / splash headlines.
  static TextStyle get displayExtraBold =>
      _s(size: 32, lineHeight: 40, weight: FontWeight.w800);

  /// `Nutq/Display/ExtraBold2` — smaller display / large section titles.
  static TextStyle get displayExtraBold2 =>
      _s(size: 24, lineHeight: 30, weight: FontWeight.w800);

  // ── Headings ───────────────────────────────────────────────────────────────
  /// `Nutq/Heading/2` — screen titles.
  static TextStyle get heading1 =>
      _s(size: 28, lineHeight: 36, weight: FontWeight.w700);

  /// `Nutq/Heading/3` — large section headers (between H1 and H2).
  static TextStyle get headingLarge =>
      _s(size: 26, lineHeight: 34, weight: FontWeight.w700);

  /// `Nutq/Heading/3b` — section headers.
  static TextStyle get heading2 =>
      _s(size: 24, lineHeight: 30, weight: FontWeight.w700);

  /// `Nutq/Label/2XL` — card & modal titles.
  static TextStyle get heading3 =>
      _s(size: 20, lineHeight: 26, weight: FontWeight.w600);

  /// `Nutq/Label/3XL` — sub-section labels.
  static TextStyle get heading4 =>
      _s(size: 22, lineHeight: 28, weight: FontWeight.w600);

  /// `Nutq/Heading/6` — compact section headings (18/700).
  static TextStyle get heading5 =>
      _s(size: 18, lineHeight: 24, weight: FontWeight.w700);

  /// `Nutq/Heading/9` — small headings (15/700).
  static TextStyle get heading6 =>
      _s(size: 15, lineHeight: 20, weight: FontWeight.w700);

  /// `Nutq/Heading/10` — small headings (14/700).
  static TextStyle get heading7 =>
      _s(size: 14, lineHeight: 20, weight: FontWeight.w700);

  /// `Nutq/Heading/11` — small headings (13/700).
  static TextStyle get heading8 =>
      _s(size: 13, lineHeight: 18, weight: FontWeight.w700);

  /// `Nutq/Heading/12` — small headings (12/700).
  static TextStyle get heading9 =>
      _s(size: 12, lineHeight: 16, weight: FontWeight.w700);

  // ── Body (400) ─────────────────────────────────────────────────────────────
  /// `Nutq/Body/XL` — largest body emphasis (19/400).
  static TextStyle get bodyXL =>
      _s(size: 19, lineHeight: 26, weight: FontWeight.w400);

  /// `Nutq/Body/MD` — primary body text.
  static TextStyle get bodyLarge =>
      _s(size: 16, lineHeight: 22, weight: FontWeight.w400);

  /// `Nutq/Body/Base` — default body copy (15/400).
  static TextStyle get bodyBase =>
      _s(size: 15, lineHeight: 22, weight: FontWeight.w400);

  /// `Nutq/Body/XS` — helper text, card meta.
  static TextStyle get bodySmall =>
      _s(size: 13, lineHeight: 18, weight: FontWeight.w400);

  /// `Nutq/Body/2XS` — timestamps, footnotes.
  static TextStyle get caption =>
      _s(size: 12, lineHeight: 16, weight: FontWeight.w400);

  /// `Nutq/Body/3XS` — smaller captions (11/400).
  static TextStyle get captionSmall =>
      _s(size: 11, lineHeight: 14, weight: FontWeight.w400);

  /// `Nutq/Body/4XS` — micro text (10/400).
  static TextStyle get micro =>
      _s(size: 10, lineHeight: 14, weight: FontWeight.w400);

  /// `Nutq/Body/5XS` — finest text (8/400).
  static TextStyle get nano =>
      _s(size: 8, lineHeight: 11, weight: FontWeight.w400);

  // ── Body Medium (500) ──────────────────────────────────────────────────────
  /// `Nutq/Body Medium/MD` — emphasized paragraphs (15/500).
  static TextStyle get bodyMediumLarge =>
      _s(size: 15, lineHeight: 22, weight: FontWeight.w500);

  /// `Nutq/Body Medium/SM` — descriptions, secondary text.
  static TextStyle get bodyMedium =>
      _s(size: 14, lineHeight: 20, weight: FontWeight.w500);

  /// `Nutq/Body Medium/XS` — emphasized helper text (13/500).
  static TextStyle get bodyMediumSmall =>
      _s(size: 13, lineHeight: 18, weight: FontWeight.w500);

  /// `Nutq/Body Medium/3XS` — emphasized smallest body (11/500).
  static TextStyle get bodyMediumTiny =>
      _s(size: 11, lineHeight: 14, weight: FontWeight.w500);

  // ── Labels (600) ───────────────────────────────────────────────────────────
  /// `Nutq/Label/LG` — large labels / buttons (16/600).
  static TextStyle get labelLarge =>
      _s(size: 16, lineHeight: 20, weight: FontWeight.w600);

  /// `Nutq/Label/MD` — medium labels (15/600).
  static TextStyle get labelMedium =>
      _s(size: 15, lineHeight: 20, weight: FontWeight.w600);

  /// `Nutq/Label/SM` — standard labels (14/600).
  static TextStyle get labelSmall =>
      _s(size: 14, lineHeight: 20, weight: FontWeight.w600);

  /// `Nutq/Label/XS` — small labels (13/600).
  static TextStyle get labelXS =>
      _s(size: 13, lineHeight: 18, weight: FontWeight.w600);

  /// `Nutq/Label/2XS` — tiny labels (12/600).
  static TextStyle get label2XS =>
      _s(size: 12, lineHeight: 16, weight: FontWeight.w600);

  /// `Nutq/Label/3XS` — chips, overlines.
  static TextStyle get label =>
      _s(size: 11, lineHeight: 14, weight: FontWeight.w600);

  /// `Nutq/Label/4XS` — smaller chip text (10/600).
  static TextStyle get labelTiny =>
      _s(size: 10, lineHeight: 14, weight: FontWeight.w600);

  /// `Nutq/Label/5XS` — smallest label (9/600).
  static TextStyle get labelMicro =>
      _s(size: 9, lineHeight: 12, weight: FontWeight.w600);

  // ── Tag (500) ──────────────────────────────────────────────────────────────
  /// `Nutq/Tag` — tag / pill text (12/500).
  static TextStyle get tag =>
      _s(size: 12, lineHeight: 16, weight: FontWeight.w500);
}
