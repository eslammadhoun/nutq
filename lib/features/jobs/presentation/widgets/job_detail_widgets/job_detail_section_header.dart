import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// Header shared by the Job Detail cards: section glyph, title and an
/// optional tag on one 26px row, then a hairline divider.
class JobDetailSectionHeader extends StatelessWidget {
  const JobDetailSectionHeader({
    super.key,
    required this.glyph,
    required this.title,
    this.tag,
  });

  final String glyph;
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
                child: Text(glyph, style: context.typography.bodyLarge),
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
