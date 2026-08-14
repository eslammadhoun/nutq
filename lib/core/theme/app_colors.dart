import 'package:flutter/material.dart';

/// Color tokens from the Nutq Figma Design System (frame 63:2, v1.0).
///
/// Job-status mapping (per DS semantic table):
///   done → success · failed → error · queued → warning · processing → info
///   cancelled → neutral
abstract final class AppColors {
  // ── Brand Blue ──────────────────────────────────────────────────────────
  static const primary50 = Color(0xFFEBF5FF);
  static const primary100 = Color(0xFFC3DDFD);
  static const primary300 = Color(0xFF76A9FA);
  static const primary400 = Color(0xFF3F83F8);
  static const primary500 = Color(0xFF1A56DB); // ★ brand primary
  static const primary600 = Color(0xFF1447BE);
  static const primary700 = Color(0xFF1339A0);
  static const primary800 = Color(0xFF0E2A82);
  static const primary900 = Color(0xFF091E63);

  static const primary = primary500;

  // ── Neutral Grey ────────────────────────────────────────────────────────
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey900 = Color(0xFF111928);

  // ── Semantic Status ─────────────────────────────────────────────────────
  static const success = Color(0xFF057A55); // done
  static const error = Color(0xFFC81E1E); // failed
  static const warning = Color(0xFFC27803); // queued
  static const info = primary500; // processing
  static const neutral = grey500; // cancelled
  static const premium = Color(0xFF7E3AF2); // accent

  // ── Status chip backgrounds (light mode) ────────────────────────────────
  static const successSurface = Color(0xFFDEF7EC); // done chip
  static const errorSurface = Color(0xFFFDE8E8); // failed chip
  static const infoSurface = primary50; // processing chip
  static const neutralSurface = grey100; // queued / cancelled chips

  // ── Dark Mode Surfaces ──────────────────────────────────────────────────
  static const darkBackground = Color(0xFF111928); // main dark bg
  static const darkSurface = Color(0xFF1F2A37); // cards, panels
  static const darkSurfaceRaised = Color(0xFF374151); // modals, sheets
  static const darkBorder = Color(0xFF4B5563); // dividers
  static const darkTextPrimary = grey50; // headings
  static const darkTextSecondary = grey400; // labels, hints
  static const darkTextDisabled = grey500; // placeholders

  // ── Light Mode Text ─────────────────────────────────────────────────────
  static const lightTextPrimary = grey900; // headings
  static const lightTextSecondary = grey400; // labels, secondary
  static const lightTextDisabled = grey400; // placeholders
}
