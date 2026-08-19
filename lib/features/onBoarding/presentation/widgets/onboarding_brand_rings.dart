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
    final double size = 360.w;

    final List<double> ringsSizes = isSplash
        ? splashRingsSizes
        : onBoardingRingsSizes;

    return RepaintBoundary(
      child: SizedBox(
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
                width: 360.w,
                height: 360.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    radius: 1.5,
                    colors: [
                      context.appColors.primary.withAlpha(40),
                      context.appColors.primary.withAlpha(0),
                    ],
                    stops: const [0.0, 1.0],
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
                    color: context.appColors.primary.withAlpha(
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
      ),
    );
  }
}
