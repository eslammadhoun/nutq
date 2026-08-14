import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/nutq_logo.dart';

class OnboardingBrandRings extends StatelessWidget {
  const OnboardingBrandRings({
    super.key,
    required this.isSplash,
    required this.iconPath,
  });

  final bool isSplash;
  final String iconPath;

  static const List<double> splashRingsSizes = [180, 132, 92];

  static const List<double> onBoardingRingsSizes = [220, 160, 108];

  static const List<int> ringsColorOpacity = [25, 32, 50];

  @override
  Widget build(BuildContext context) {
    final double size = isSplash ? 360.w : 280.w;

    final List<double> ringsSizes = isSplash
        ? splashRingsSizes
        : onBoardingRingsSizes;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ============================================================
          // BLUE GLOW
          // ============================================================
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: isSplash ? 360.w : 280.w,
              height: isSplash ? 360.w : 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  radius: 1.0,
                  colors: [
                    context.colorsTheme.primary.withAlpha(
                      context.brightness == Brightness.dark ? 180 : 120,
                    ),
                    context.colorsTheme.primary.withAlpha(70),
                    context.colorsTheme.primary.withAlpha(0),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ============================================================
          // RINGS
          // ============================================================
          ...List.generate(ringsSizes.length, (index) {
            final double ringSize = ringsSizes[index].w;

            return Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorsTheme.primary.withAlpha(
                    ringsColorOpacity[index],
                  ),
                  width: 1,
                ),
              ),
            );
          }),

          // ============================================================
          // LOGO
          // ============================================================
          NutqLogo(
            size: isSplash ? 80 : 96,
            iconPath: iconPath,
            borderRadius: isSplash ? 20 : 24,
          ),
        ],
      ),
    );
  }
}
