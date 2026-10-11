import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/app_icon.dart';

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
    final l10n = context.l10n;

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
              iconPath: AppIcons.home,
              activeIconPath: AppIcons.homeActive,
              label: l10n.navHome,
              tab: AppNavTab.home,
              isActive: current == AppNavTab.home,
              onTap: () => onTap(AppNavTab.home),
            ),
            _NavItem(
              iconPath: AppIcons.alerts,
              activeIconPath: AppIcons.alertsActive,
              label: l10n.navAlerts,
              tab: AppNavTab.alerts,
              isActive: current == AppNavTab.alerts,
              badgeCount: alertsBadgeCount,
              onTap: () => onTap(AppNavTab.alerts),
            ),
            _NavItem(
              iconPath: AppIcons.profile,
              activeIconPath: AppIcons.profileActive,
              label: l10n.navProfile,
              tab: AppNavTab.profile,
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
    required this.iconPath,
    required this.activeIconPath,
    required this.label,
    required this.tab,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  /// Outline icon while idle, filled when this tab is open.
  final String iconPath;
  final String activeIconPath;
  final String label;
  final AppNavTab tab;
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
                    AppIcon(
                      isActive ? activeIconPath : iconPath,
                      size: 24.w,
                      color: isActive ? colors.primary : colors.textSecondary,
                    ),
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
                child: badgeCount > 0
                    ? Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: colors.statusFailed,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badgeCount > 9 ? '9+' : '$badgeCount',
                            style: context.typography.labelMicro.copyWith(
                              color: colors.textInverse,
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
