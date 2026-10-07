import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:nutq/core/widgets/app_switch.dart';
import 'package:nutq/features/profile/presentation/cubit/notifications_cubit.dart';
import 'package:nutq/features/profile/presentation/widgets/settings_group.dart';

/// PREFERENCES (Figma "Profile & Settings" 9:523): dark mode, the "Summary
/// ready" notification, and the app language.
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return SettingsGroup(
      title: l10n.profilePreferences,
      children: [
        SettingsRow(
          icon: Icons.dark_mode_rounded,
          iconColor: colors.accentPremium,
          iconBackground: colors.accentPremiumBg,
          title: l10n.profileDarkMode,
          // On while the app is dark, including when it follows a dark phone;
          // flipping it picks light or dark for good.
          trailing: _SwitchSlot(
            child: AppSwitch(
              value: context.isDark,
              label: l10n.profileDarkMode,
              onChanged: (dark) =>
                  context.read<ThemeCubit>().setThemeMode(dark ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
        ),
        SettingsRow(
          icon: Icons.notifications_rounded,
          iconColor: colors.statusWarning,
          iconBackground: colors.statusWarningBg,
          title: l10n.profileNotifications,
          trailing: _SwitchSlot(
            child: BlocBuilder<NotificationsCubit, bool>(
              builder: (context, enabled) => AppSwitch(
                value: enabled,
                label: l10n.profileNotifications,
                onChanged: context.read<NotificationsCubit>().setEnabled,
              ),
            ),
          ),
        ),
        SettingsRow(
          icon: Icons.language_rounded,
          iconColor: colors.statusProcessing,
          iconBackground: colors.statusProcessingBg,
          title: l10n.profileLanguage,
          trailing: SettingsValue(
            Localizations.localeOf(context).languageCode == 'ar'
                ? l10n.languageArabic
                : l10n.languageEnglish,
          ),
          onTap: () => _pickLanguage(context),
        ),
      ],
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final l10n = context.l10n;
    final colors = context.appColors;
    final current = Localizations.localeOf(context).languageCode;
    final cubit = context.read<LocaleCubit>();
    final code = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (value, name) in [
                ('ar', l10n.languageArabic),
                ('en', l10n.languageEnglish),
              ])
                ListTile(
                  title: Text(
                    name,
                    style: context.typography.bodyMedium.copyWith(color: colors.textPrimary),
                  ),
                  trailing: value == current
                      ? Icon(Icons.check_rounded, color: colors.primary, size: 20.w)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, value),
                ),
            ],
          ),
        ),
      ),
    );
    if (code != null && code != current) await cubit.setLocale(Locale(code));
  }
}

/// Switch rows sit 6pt further from the edge than value rows, as designed.
class _SwitchSlot extends StatelessWidget {
  const _SwitchSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(end: 6.w),
    child: child,
  );
}
