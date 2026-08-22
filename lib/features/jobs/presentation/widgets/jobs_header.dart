import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

class JobsHeader extends StatelessWidget {
  const JobsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('History', style: context.typography.headingLarge),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: BoxBorder.all(color: colors.borderDefault),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 18.sp,
                  color: colors.textPrimary,
                ),
              ),
              Positioned(
                right: 6.w,
                top: -2,
                child: Center(
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: colors.statusFailed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.borderDefault,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
