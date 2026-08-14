import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const List<String> fontFamilyFallback = ['NotoSansArabic'];

  static TextStyle get display => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32.sp,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get heading1 => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28.sp,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24.sp,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20.sp,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get heading4 => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18.sp,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16.sp,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14.sp,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13.sp,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12.sp,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );

  /// Chips, overlines. (The DS doc mentioned 0.8 px tracking, but the actual
  /// `Nutq/Label/3XS` Figma variable has 0 — token wins.)
  static TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11.sp,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    headlineLarge: heading1,
    headlineMedium: heading2,
    headlineSmall: heading3,
    titleLarge: heading4,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelMedium: caption,
    labelSmall: label,
  );
}
