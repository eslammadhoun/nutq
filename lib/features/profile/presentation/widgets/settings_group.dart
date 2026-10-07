import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

/// A titled card of settings rows (Figma "Profile & Settings", e.g.
/// PREFERENCES).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w),
          child: Text(
            title.toUpperCase(),
            style: context.typography.label.copyWith(color: colors.textSecondary),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: dark ? Border.all(color: colors.borderDefault) : null,
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                offset: Offset(0, dark ? 4.h : 2.h),
                blurRadius: 12.r,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// One row of a [SettingsGroup]: an icon on a tinted tile, a title, and a
/// trailing control or value.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44.h,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 14.w, end: 18.w),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.w, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: context.typography.bodyMedium.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A [SettingsRow] trailing value with the "›" that says the row opens more.
class SettingsValue extends StatelessWidget {
  const SettingsValue(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: context.typography.caption.copyWith(color: colors.textSecondary)),
        SizedBox(width: 22.w),
        // A bidi-mirrored character: it points the other way in Arabic.
        Text(
          '›',
          style: context.typography.heading5.copyWith(
            color: colors.iconMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
