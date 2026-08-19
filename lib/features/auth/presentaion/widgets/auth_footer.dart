import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class AuthFooter extends StatelessWidget {
  final String staticText;
  final String actionText;
  final VoidCallback onActionTap;

  const AuthFooter({
    super.key,
    required this.staticText,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              staticText,
              style: context.typography.labelSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText,
                style: context.typography.labelMedium.copyWith(
                  color: context.appColors.textBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}