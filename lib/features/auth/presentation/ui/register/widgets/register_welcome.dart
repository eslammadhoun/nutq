import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class RegisterWelcome extends StatelessWidget {
  const RegisterWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 26.h),
        Text(
          l10n.registerWelcomeTitle,
          style: context.typography.heading1.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.registerWelcomeSubtitle,
          style: context.typography.bodyBase.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
