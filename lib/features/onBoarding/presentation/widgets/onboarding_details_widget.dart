import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_brand_rings.dart';

class OnboardingDetailsWidget extends StatelessWidget {
  final int selectedIndex;
  const OnboardingDetailsWidget({super.key, required this.selectedIndex});

  static const List<Map<String, String>> onBoardingData = [
    {
      'icon-path': 'assets/svgs/nutq-icon.svg',
      'title': 'Turn Arabic Speech\ninto Text',
      'subTitle':
          'Record or upload any audio — Nutq\ntranscribes it in seconds with precision.',
    },
    {
      'icon-path': 'assets/svgs/onBoarding-2-icon.svg',
      'title': 'AI-Powered\nSummaries',
      'subTitle':
          'Get smart summaries, key takeaways,\nand insights from every transcription.',
    },
    {
      'icon-path': 'assets/svgs/onBoarding-3-icon.svg',
      'title': 'Browse Your\nHistory',
      'subTitle':
          'Search, share, and export all your\npast transcriptions with ease.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              OnboardingBrandRings(
                isSplash: false,
                iconPath: onBoardingData[selectedIndex]['icon-path']!,
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  onBoardingData[selectedIndex]['title']!,
                  style: context.typography.heading1.copyWith(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          onBoardingData[selectedIndex]['subTitle']!,
          style: context.typography.bodyBase.copyWith(
            color: context.appColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
