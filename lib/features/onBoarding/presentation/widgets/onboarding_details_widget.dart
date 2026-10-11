import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_brand_rings.dart';
import 'package:nutq/l10n/app_localizations.dart';

class OnboardingDetailsWidget extends StatelessWidget {
  final int selectedIndex;
  const OnboardingDetailsWidget({super.key, required this.selectedIndex});

  static const List<String> _iconPaths = [
    'assets/svgs/nutq-icon.svg',
    'assets/svgs/onBoarding-2-icon.svg',
    'assets/svgs/onBoarding-3-icon.svg',
  ];

  List<({String title, String subTitle})> _slides(AppLocalizations l10n) => [
    (title: l10n.onboardingSlide1Title, subTitle: l10n.onboardingSlide1Subtitle),
    (title: l10n.onboardingSlide2Title, subTitle: l10n.onboardingSlide2Subtitle),
    (title: l10n.onboardingSlide3Title, subTitle: l10n.onboardingSlide3Subtitle),
  ];

  @override
  Widget build(BuildContext context) {
    final slide = _slides(context.l10n)[selectedIndex];
    return Column(
      children: [
        SizedBox(
          height: 300.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              OnboardingBrandRings(
                isSplash: false,
                iconPath: _iconPaths[selectedIndex],
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  slide.title,
                  style: context.typography.heading1.copyWith(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          slide.subTitle,
          style: context.typography.bodyBase.copyWith(
            color: context.appColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
