import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class GlobalButton extends StatelessWidget {
  final bool isFilled;
  final void Function()? onTap;
  final String text;
  const GlobalButton({
    super.key,
    required this.isFilled,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 340.w,
        height: 52.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: BoxBorder.all(
            color: isFilled
                ? Colors.transparent
                : context.isDark
                ? Colors.white.withAlpha(50)
                : context.appColors.primary.withAlpha(50),
          ),
          color: isFilled
              ? context.appColors.primary
              : context.isDark
              ? Colors.white.withAlpha(20)
              : context.appColors.primary.withAlpha(20),
          boxShadow: isFilled
              ? [
                  BoxShadow(
                    color: context.appColors.primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: context.typography.labelLarge.copyWith(
              color: isFilled
                  ? Colors.white
                  : context.isDark
                  ? context.appColors.textPrimary
                  : context.appColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
