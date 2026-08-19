import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 62.h),
        Center(
          child: Container(
            width: 44.w,
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: context.appColors.primary,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                context.isDark
                    ? BoxShadow(
                        color: context.appColors.primary.withValues(
                          alpha: 0.55,
                        ),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    : BoxShadow(
                        color: context.appColors.primary.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: Offset(0, 4.h),
                      ),
              ],
            ),
            child: Center(child: SvgPicture.asset('assets/svgs/nutq-icon.svg')),
          ),
        ),
        SizedBox(height: 14.h),
        Center(
          child: Text(
            'Nutq',
            style: context.typography.headingLarge.copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
