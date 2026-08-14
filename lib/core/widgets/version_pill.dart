import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/theme/app_typography.dart';

/// Small tinted pill showing the app version (Figma splash "v 1.0" badge).
class VersionPill extends StatelessWidget {
  const VersionPill({super.key, this.version = '1.0'});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      width: 64.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.brightness == Brightness.dark
            ? Color(0xffffffff).withValues(alpha: 0.10)
            : context.colorsTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: context.brightness == Brightness.dark
              ? Color(0xffffffff).withValues(alpha: 0.22)
              : context.colorsTheme.primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        'v $version',
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colorsTheme.onSurface,
        ),
      ),
    );
  }
}
