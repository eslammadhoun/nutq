import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/core/widgets/global_button.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_details_widget.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_screens_dots.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int selectedIndex = 0;
  final AppPreferences appPreferences = sl<AppPreferences>();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                    onTap: _finish,
                    child: Text(
                      selectedIndex != 2 ? l10n.onboardingSkip : '',
                      style: context.typography.bodyMediumLarge.copyWith(
                        color: context.appColors.textSecondary,
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
              text: selectedIndex != 2 ? l10n.onboardingNext : l10n.onboardingGetStarted,
            ),
          ],
        ),
      ),
    );
  }

  /// Onboarding ends by offering the model download, unless the models are
  /// already on the phone.
  void _finish() {
    appPreferences.setSeenOnboarding();
    final models = sl<ModelRepository>();
    final ready = models
        .requiredFor(JobSourceType.audio, ContentLanguage.ar)
        .every((pack) => models.statuses[pack.id]!.isReady);
    context.pushNamedAndRemoveUntil(ready ? Routes.home : Routes.modelDownload);
  }

  void changeSelectedIndex(int newIndex) {
    if (newIndex >= 3) {
      _finish();
      return;
    }

    setState(() {
      selectedIndex = newIndex;
    });
  }
}
