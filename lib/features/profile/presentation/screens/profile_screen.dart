import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:nutq/core/widgets/version_pill.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/profile/presentation/cubit/profile_cubit.dart';

/// Settings: appearance, language, storage, about. Everything is on the phone,
/// so there is no account to show.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(25.w, 10.h, 25.w, 24.h),
          children: [
            Text(l10n.profileTitle, style: context.typography.headingLarge),
            SizedBox(height: 18.h),
            _Section(title: l10n.profileAppearance, child: const _ThemePicker()),
            _Section(title: l10n.profileLanguage, child: const _LanguagePicker()),
            _Section(title: l10n.profileStorage, child: const _Storage()),
            _Section(
              title: l10n.profileAbout,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.profileVersion,
                          style: context.typography.bodySmall.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ),
                      const VersionPill(),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    l10n.profileOnDevice,
                    style: context.typography.captionSmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.label.copyWith(color: colors.textSecondary)),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A row of choices; the selected one is filled.
class _Choices<T> extends StatelessWidget {
  const _Choices({required this.options, required this.selected, required this.onSelect});

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        for (final (value, label) in options)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Material(
                color: value == selected ? colors.primary : colors.subtle,
                borderRadius: BorderRadius.circular(10.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: () => onSelect(value),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.typography.labelSmall.copyWith(
                        color: value == selected ? colors.textInverse : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => _Choices<ThemeMode>(
        options: [
          (ThemeMode.system, l10n.profileThemeSystem),
          (ThemeMode.light, l10n.profileThemeLight),
          (ThemeMode.dark, l10n.profileThemeDark),
        ],
        selected: mode,
        onSelect: (m) => context.read<ThemeCubit>().setThemeMode(m),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = Localizations.localeOf(context).languageCode;
    return _Choices<String>(
      options: [('ar', l10n.languageArabic), ('en', l10n.languageEnglish)],
      selected: current,
      onSelect: (code) => context.read<LocaleCubit>().setLocale(Locale(code)),
    );
  }
}

class _Storage extends StatelessWidget {
  const _Storage();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final usage = state.usage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              usage == null
                  ? '…'
                  : l10n.profileStorageSummary(usage.jobs, formatBytes(usage.mediaBytes)),
              style: context.typography.bodySmall.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: 10.h),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: colors.statusFailedBg,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: state.deleting || (usage?.jobs ?? 0) == 0
                  ? null
                  : () => _confirmDeleteAll(context),
              child: Text(
                l10n.profileDeleteAll,
                style: context.typography.labelSmall.copyWith(color: colors.statusFailed),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<ProfileCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileDeleteAllTitle),
        content: Text(l10n.profileDeleteAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.profileDeleteAllConfirm,
              style: context.typography.labelMedium.copyWith(
                color: context.appColors.statusFailed,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.deleteAllJobs();
  }
}
