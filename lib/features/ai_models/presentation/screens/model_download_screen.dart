import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/navigation_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/ai_models/presentation/widgets/model_download_panel.dart';
import 'package:nutq/features/onBoarding/presentation/widgets/onboarding_brand_rings.dart';

/// The last step of onboarding: download the models now, or later (the first
/// job then asks for them). Leaving keeps a running download going.
class ModelDownloadScreen extends StatelessWidget {
  const ModelDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void goHome() => context.pushNamedAndRemoveUntil(Routes.home);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: InkWell(
                    onTap: goHome,
                    child: Text(
                      context.l10n.modelsLater,
                      style: context.typography.bodyMediumLarge.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                height: 260.h,
                child: const OnboardingBrandRings(
                  isSplash: false,
                  iconPath: 'assets/svgs/nutq-icon.svg',
                ),
              ),
              const Spacer(),
              ModelDownloadPanel(title: context.l10n.modelsTitle, onDone: goHome),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
