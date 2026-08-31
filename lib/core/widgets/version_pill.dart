import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/theme/app_typography.dart';

/// Small tinted pill showing the app version (Figma splash "v 1.0" badge).
///
/// Reads the real version from the native bundle (pubspec.yaml →
/// Info.plist / build.gradle) via package_info_plus, so bumping the version
/// in pubspec.yaml is the single source of truth.
class VersionPill extends StatefulWidget {
  const VersionPill({super.key});

  @override
  State<VersionPill> createState() => _VersionPillState();
}

class _VersionPillState extends State<VersionPill> {
  Future<PackageInfo>? _info;

  @override
  void initState() {
    super.initState();
    _info = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      width: 64.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.isDark
            ? Color(0xffffffff).withValues(alpha: 0.10)
            : context.appColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: context.isDark
              ? Color(0xffffffff).withValues(alpha: 0.22)
              : context.appColors.primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snapshot) {
          final version = snapshot.data?.version;
          return Text(
            context.l10n.versionLabel(version ?? ''),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: context.isDark
                  ? context.appColors.textPrimary
                  : context.appColors.primary,
            ),
          );
        },
      ),
    );
  }
}
