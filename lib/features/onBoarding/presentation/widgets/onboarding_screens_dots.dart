import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class OnboardingScreensDots extends StatelessWidget {
  final int selectedIndex;

  const OnboardingScreensDots({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isSelected = selectedIndex == index;
        return Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 8.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 28.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorsTheme.primary
                  : context.isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : context.colorsTheme.primary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      }),
    );
  }
}
