import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// The launch screen's design (Figma "Splash — Light" 11:2 and "Splash —
/// Dark" 2017:2), minus the background gradient: a 390×844 transparent layer.
///
/// The app shows no splash of its own; this is rendered to the iOS launch
/// image by `tool/native_splash/render_test.dart`, which also renders the
/// gradient. Re-run it after changing this widget.
///
/// Sizes are plain design points, not ScreenUtil units: the image is drawn at
/// the design's size and the launch screen centers it.
class SplashArt extends StatelessWidget {
  const SplashArt({super.key});

  static const Size size = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final type = context.typography;
    final dark = context.isDark;
    const white = Color(0xFFFFFFFF);

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        children: [
          // Glow, rings and logo, centered on x 195. The dark frame sits the
          // group 28pt higher than the light one.
          Positioned(
            left: 195 - 204,
            top: (dark ? 310 : 338) - 204,
            child: _Mark(dark: dark),
          ),
          _centered(
            top: 380,
            Text(
              'Nutq',
              style: type.display.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _centered(
            top: 450,
            Text('نُطق', style: type.bodyXL.copyWith(color: colors.textBrand)),
          ),
          _centered(
            top: 481,
            Container(
              width: 56,
              height: 1,
              decoration: BoxDecoration(
                color: dark ? white.withValues(alpha: 0.15) : colors.textInverse,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _centered(
            top: 500,
            Text(
              'Arabic Speech Transcription',
              style: type.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
          _centered(
            top: 628,
            Container(
              width: 64,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? white.withValues(alpha: 0.10) : colors.primary,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: dark ? white.withValues(alpha: 0.22) : colors.primary,
                ),
              ),
              child: Text(
                'v 1.0',
                style: type.tag.copyWith(color: dark ? colors.textPrimary : colors.textInverse),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _centered(Widget child, {required double top}) => Positioned(
    top: top,
    left: 0,
    right: 0,
    child: Center(child: child),
  );
}

/// The 408pt square around the logo: blurred glow, three rings, and the logo
/// with its two shadows, as in the design's SVG export.
class _Mark extends StatelessWidget {
  const _Mark({required this.dark});

  final bool dark;

  /// A blurred rounded square: one of the logo's shadows. Drawn as a blur
  /// rather than a [BoxShadow] so that the sigma is exactly the design's and
  /// renders the same everywhere.
  static Widget _shadow({
    required Color color,
    required double sigma,
    double spread = 0,
    double dy = 0,
  }) => Transform.translate(
    offset: Offset(0, dy),
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        width: 80 + spread * 2,
        height: 80 + spread * 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20 + spread),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    final ring = dark ? const Color(0xFFFFFFFF) : primary;

    return SizedBox.square(
      dimension: 408,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // Fades out 360pt from the center, as in the design; the
                  // radius is a fraction of the box's side (360).
                  radius: 1,
                  colors: [
                    primary.withValues(alpha: dark ? 0.30 : 0.14),
                    primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          for (final (diameter, opacity) in [(180.0, 0.08), (132.0, 0.13), (92.0, 0.20)])
            Container(
              // The stroke is centered on the circle, like the SVG's.
              width: diameter + 1,
              height: diameter + 1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring.withValues(alpha: opacity)),
              ),
            ),
          _shadow(color: primary.withValues(alpha: 0.3), sigma: 14, dy: 8),
          _shadow(color: primary.withValues(alpha: 0.6), sigma: 10, spread: 4),
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
            child: SvgPicture.asset('assets/svgs/nutq-icon.svg', width: 50, height: 40),
          ),
        ],
      ),
    );
  }
}
