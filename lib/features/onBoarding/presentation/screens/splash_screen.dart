import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/version_pill.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_brand_rings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        context.pushNamedAndRemoveUntil(Routes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 360.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  OnboardingBrandRings(
                    isSplash: true,
                    iconPath: 'assets/svgs/nutq-icon.svg',
                  ),
                  Positioned(
                    top: 220.h,
                    child: Text('Nutq', style: context.typography.display),
                  ),
                  Positioned(
                    bottom: 40,
                    child: Column(
                      children: [
                        Text(
                          'نُطق',
                          style: context.typography.bodyXL.copyWith(
                            color: context.colorsTheme.primary,
                            fontSize: 19,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 1.h,
                          width: 56.w,
                          decoration: BoxDecoration(
                            color: context.colorsTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    child: Column(
                      children: [
                        Text(
                          'Arabic Speech Transcription',
                          style: context.typography.bodySmall.copyWith(
                            color: context.colorsTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 110.h),
            VersionPill(),
          ],
        ),
      ),
    );
  }
}
