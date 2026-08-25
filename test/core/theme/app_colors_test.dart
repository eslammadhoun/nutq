import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/theme/app_colors.dart';

void main() {
  const lightHex = {
    'primary': '#1A56DB',
    'primaryDark': '#1648C0',
    'primaryLight': '#EBF1FF',
    'primaryLighter': '#EBF5FF',
    'primary300': '#76A9FA',
    'base': '#FFFFFF',
    'surface': '#FFFFFF',
    'card': '#FFFFFF',
    'subtle': '#F3F4F6',
    'page': '#F8FAFC',
    'overlay': '#11182A',
    'textPrimary': '#111827',
    'textSecondary': '#6B7380',
    'textBrand': '#1A56DB',
    'textInverse': '#FFFFFF',
    'textMuted': '#9CA3AF',
    'textTertiary': '#374151',
    'borderSubtle': '#E2E8F0',
    'borderDefault': '#E5E7EB',
    'statusDone': '#059669',
    'statusDoneBg': '#ECFDF5',
    'statusProcessing': '#2563EB',
    'statusProcessingBg': '#EFF6FF',
    'statusQueued': '#64748B',
    'statusQueuedBg': '#F1F5F9',
    'statusFailed': '#DC2626',
    'statusFailedBg': '#FEF2F2',
    'statusCancelled': '#6B7280',
    'statusCancelledBg': '#F3F4F6',
    'statusWarning': '#C27803',
    'statusWarningBg': '#FDF3D3',
    'sourceWeb': '#0891B2',
    'navBarBg': '#FFFFFF',
    'navIndicator': '#1A56DB',
    'scrimOverlay': '#11182A',
  };

  const darkHex = {
    'primary': '#1A56DB',
    'primaryDark': '#76A9FA',
    'primaryLight': '#1E3A5F',
    'primaryLighter': '#0F2040',
    'primary300': '#93C5FD',
    'base': '#111928',
    'surface': '#1F2937',
    'card': '#374151',
    'subtle': '#161F2C',
    'page': '#0D1117',
    'overlay': '#000000',
    'textPrimary': '#F9FAFB',
    'textSecondary': '#9CA3AF',
    'textBrand': '#76A9FA',
    'textInverse': '#FFFFFF',
    'textMuted': '#6B7280',
    'textTertiary': '#6B7280',
    'borderSubtle': '#1F2A37',
    'borderDefault': '#374151',
    'statusDone': '#34D399',
    'statusDoneBg': '#064E3B',
    'statusProcessing': '#60A5FA',
    'statusProcessingBg': '#1E3A5F',
    'statusQueued': '#9CA3AF',
    'statusQueuedBg': '#1F2A37',
    'statusFailed': '#DC2626',
    'statusFailedBg': '#450A0A',
    'statusCancelled': '#6B7280',
    'statusCancelledBg': '#1F2A37',
    'statusWarning': '#FBBF24',
    'statusWarningBg': '#451A03',
    'sourceWeb': '#22D3EE',
    'navBarBg': '#1F2A37',
    'navIndicator': '#4F83F1',
    'scrimOverlay': '#000000',
  };

  Color nameOf(AppColors c, String field) {
    switch (field) {
      case 'primary':
        return c.primary;
      case 'primaryDark':
        return c.primaryDark;
      case 'primaryLight':
        return c.primaryLight;
      case 'primaryLighter':
        return c.primaryLighter;
      case 'primary300':
        return c.primary300;
      case 'base':
        return c.base;
      case 'surface':
        return c.surface;
      case 'card':
        return c.card;
      case 'subtle':
        return c.subtle;
      case 'page':
        return c.page;
      case 'overlay':
        return c.overlay;
      case 'textPrimary':
        return c.textPrimary;
      case 'textSecondary':
        return c.textSecondary;
      case 'textBrand':
        return c.textBrand;
      case 'textInverse':
        return c.textInverse;
      case 'textMuted':
        return c.textMuted;
      case 'textTertiary':
        return c.textTertiary;
      case 'borderSubtle':
        return c.borderSubtle;
      case 'borderDefault':
        return c.borderDefault;
      case 'statusDone':
        return c.statusDone;
      case 'statusDoneBg':
        return c.statusDoneBg;
      case 'statusProcessing':
        return c.statusProcessing;
      case 'statusProcessingBg':
        return c.statusProcessingBg;
      case 'statusQueued':
        return c.statusQueued;
      case 'statusQueuedBg':
        return c.statusQueuedBg;
      case 'statusFailed':
        return c.statusFailed;
      case 'statusFailedBg':
        return c.statusFailedBg;
      case 'statusCancelled':
        return c.statusCancelled;
      case 'statusCancelledBg':
        return c.statusCancelledBg;
      case 'statusWarning':
        return c.statusWarning;
      case 'statusWarningBg':
        return c.statusWarningBg;
      case 'sourceWeb':
        return c.sourceWeb;
      case 'navBarBg':
        return c.navBarBg;
      case 'navIndicator':
        return c.navIndicator;
      case 'scrimOverlay':
        return c.scrimOverlay;
      default:
        throw ArgumentError('Unknown field: $field');
    }
  }

  String hexOf(Color c) {
    final value = c.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void expectEveryToken(AppColors colors, Map<String, String> expected) {
    final mode = identical(colors, AppColors.light) ? 'light' : 'dark';
    expect(
      expected.keys.length,
      35,
      reason: 'expected exactly 35 color tokens to be checked',
    );
    for (final entry in expected.entries) {
      expect(
        hexOf(nameOf(colors, entry.key)),
        entry.value,
        reason: '${entry.key} ($mode)',
      );
    }
  }

  group('AppColors tokens', () {
    test('light instances carry the exact Light.tokens.json values', () {
      expectEveryToken(AppColors.light, lightHex);
    });

    test('dark instances carry the exact Dark.tokens.json values', () {
      expectEveryToken(AppColors.dark, darkHex);
    });

    test('light and dark are distinct const instances', () {
      expect(identical(AppColors.light, AppColors.dark), isFalse);
      // primary is intentionally the same brand blue in both modes;
      // base (white vs dark navy) is what flips.
      expect(AppColors.light.base, isNot(AppColors.dark.base));
    });

    test('copyWith overrides only the requested field', () {
      final updated = AppColors.light.copyWith(
        primary: const Color(0xFF000000),
      );
      expect(updated.primary, const Color(0xFF000000));
      expect(updated.textPrimary, AppColors.light.textPrimary);
      expect(updated.primaryDark, AppColors.light.primaryDark);
    });

    test('lerp blends toward the other instance', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(mid.base, isNot(AppColors.light.base));
      expect(mid.base, isNot(AppColors.dark.base));
    });

    test('resolves from ThemeData.extensions', () {
      final theme = ThemeData(extensions: const [AppColors.light]);
      expect(theme.extension<AppColors>(), same(AppColors.light));
    });
  });
}
