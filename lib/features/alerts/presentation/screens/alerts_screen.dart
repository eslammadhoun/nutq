import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/routing/routes.dart';
import 'package:nutq/features/alerts/domain/job_alert.dart';
import 'package:nutq/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';

/// Finished and failed jobs, newest first. Tap opens the job, swipe dismisses
/// one, "Clear all" dismisses every one listed.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: BlocBuilder<AlertsCubit, AlertsState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.alertsTitle, style: context.typography.headingLarge),
                    ),
                    if (state.alerts.isNotEmpty)
                      TextButton(
                        onPressed: () => context.read<AlertsCubit>().clearAll(),
                        child: Text(
                          l10n.alertsClearAll,
                          style: context.typography.labelMedium.copyWith(color: colors.primary),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: !state.loaded
                      ? const SizedBox.shrink()
                      : state.alerts.isEmpty
                      ? Center(
                          child: Text(
                            l10n.alertsEmpty,
                            textAlign: TextAlign.center,
                            style: context.typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 24.h),
                          itemCount: state.alerts.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, i) {
                            final alert = state.alerts[i];
                            return Dismissible(
                              key: ValueKey(alert.jobId),
                              onDismissed: (_) => context.read<AlertsCubit>().dismiss(alert.jobId),
                              child: AlertTile(
                                alert: alert,
                                unread: state.unread.contains(alert.jobId),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, required this.unread});

  final JobAlert alert;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final failure = alert.failure;
    final accent = failure == null ? colors.statusDone : colors.statusFailed;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => Navigator.pushNamed(context, Routes.jobDetail, arguments: alert.jobId),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: failure == null ? colors.statusDoneBg : colors.statusFailedBg,
                ),
                child: Icon(
                  failure == null ? Icons.check_rounded : Icons.error_outline_rounded,
                  size: 18.sp,
                  color: accent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      failure == null ? l10n.alertJobDone : l10n.alertJobFailed,
                      style: context.typography.labelMedium.copyWith(color: colors.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      alert.title.isEmpty ? l10n.alertsUntitled : alert.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.bodySmall.copyWith(color: colors.textSecondary),
                    ),
                    if (failure != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        jobFailureMessage(l10n, failure),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.captionSmall.copyWith(color: colors.statusFailed),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      formatRelativeTime(context, alert.at),
                      style: context.typography.captionSmall.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.w, top: 4.h),
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
