import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// Nutq brand mark: brand-blue rounded square with a white audio waveform.
/// Scales proportionally from the 80 px Figma spec via [size].
class NutqLogo extends StatelessWidget {
  const NutqLogo({
    super.key,
    required this.size,
    required this.iconPath,
    required this.borderRadius,
  });

  final double size;
  final String iconPath;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.3),
            blurRadius: 28.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: context.appColors.primary.withValues(alpha: 0.6),
            blurRadius: 20.r,
            offset: Offset(0, 0),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: SvgPicture.asset(iconPath)),
    );
  }
}
