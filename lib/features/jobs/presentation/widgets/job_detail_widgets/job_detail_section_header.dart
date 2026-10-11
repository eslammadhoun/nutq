import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/app_icon.dart';

/// Header shared by the Job Detail cards: section icon, title and an
/// optional tag on one 26px row, then a hairline divider.
class JobDetailSectionHeader extends StatelessWidget {
  const JobDetailSectionHeader({
    super.key,
    required this.iconPath,
    required this.title,
    this.tag,
  });

  /// An [AppIcons] path.
  final String iconPath;
  final String title;
  final Widget? tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 26.h,
          child: Row(
            children: [
              SizedBox(
                width: 20.w,
                child: AppIcon(iconPath, size: 20.w, color: colors.primary),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: context.typography.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              ?tag,
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Container(height: 1, color: colors.borderDefault),
        SizedBox(height: 9.h),
      ],
    );
  }
}
