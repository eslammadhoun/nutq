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
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.scrimOverlay.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
