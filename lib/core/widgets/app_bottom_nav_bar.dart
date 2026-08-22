import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';

enum AppNavTab { home, alerts, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.current,
    required this.onTap,
    this.alertsBadgeCount = 0,
  });

  final AppNavTab current;
  final void Function(AppNavTab tab) onTap;
  final int alertsBadgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.navBarBg,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SizedBox(
        height: 82.h,
        child: Row(
          children: [
            _NavItem(
              emoji: '🏠',
              label: 'Home',
              isActive: current == AppNavTab.home,
              onTap: () => onTap(AppNavTab.home),
            ),
            _NavItem(
              emoji: '🔔',
              label: 'Alerts',
              isActive: current == AppNavTab.alerts,
              badgeCount: alertsBadgeCount,
              onTap: () => onTap(AppNavTab.alerts),
            ),
            _NavItem(
              emoji: '👤',
              label: 'Profile',
              isActive: current == AppNavTab.profile,
              onTap: () => onTap(AppNavTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 82.h,
      width: (MediaQuery.of(context).size.width.w) / 3.w,
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: isActive
                    ? Container(
                        width: 32.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: colors.navIndicator,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                    : const SizedBox(),
              ),
              Positioned(
                top: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(emoji, style: TextStyle(fontSize: 22.sp)),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      style: context.typography.captionSmall.copyWith(
                        color: isActive ? colors.primary : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12.h,
                right: 48.w,
                child: label == 'Alerts'
                    ? Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '3',
                            style: context.typography.labelMicro.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
