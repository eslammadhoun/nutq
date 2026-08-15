import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_details_widget.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_screens_dots.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 25, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => context.pushNamedAndRemoveUntil(Routes.login),
                    child: Text(
                      selectedIndex != 2 ? 'Skip' : '',
                      style: context.typography.bodyMediumLarge.copyWith(
                        color: context.colorsTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.h),
            OnboardingDetailsWidget(selectedIndex: selectedIndex),
            const Spacer(),
            OnboardingScreensDots(selectedIndex: selectedIndex),
            SizedBox(height: 34.h),
            GlobalButton(
              isFilled: selectedIndex == 2,
              onTap: () => changeSelectedIndex(selectedIndex + 1),
              text: selectedIndex != 2 ? 'Next' : 'Get Started',
            ),
          ],
        ),
      ),
    );
  }

  void changeSelectedIndex(int newIndex) {
    if (newIndex >= 3) {
      context.pushNamedAndRemoveUntil(Routes.login);
      return;
    }

    setState(() {
      selectedIndex = newIndex;
    });
  }
}
