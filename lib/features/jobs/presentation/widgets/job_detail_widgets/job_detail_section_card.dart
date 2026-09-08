import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class JobDetailSectionCard extends StatelessWidget {
  const JobDetailSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.cardMuted,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: colors.scrimOverlay.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
