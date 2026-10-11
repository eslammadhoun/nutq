import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class JobDetailAppBar extends StatelessWidget {
  const JobDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 56.h,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.borderDefault)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 24.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              context.l10n.jobDetailTitle,
              style: context.typography.labelLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.more_horiz_rounded,
            size: 24.sp,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
