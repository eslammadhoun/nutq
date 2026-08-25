import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';
import 'package:nutq/l10n/app_localizations.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final source = _sourceVisual(context, job.sourceType);
    final status = _statusVisual(context, job.status);

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: source.color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    source.icon,
                    size: 14.sp,
                    color: colors.textInverse,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    source.label,
                    style: context.typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Text(
                    status.label,
                    style: context.typography.labelMicro.copyWith(
                      color: status.color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              job.subtitle ?? l10n.jobFallbackTitle(_shortId(job.id)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${_formatTimestamp(context, job.createdAt)} · ${_languageName(l10n, job.languageCode)}',
              style: context.typography.captionSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Locale-aware "Today, h:mm a" / "Yesterday" / "Jan 5" label. intl
  /// localizes AM/PM and month names per locale (e.g. ص/م in Arabic).
  String _formatTimestamp(BuildContext context, DateTime utc) {
    final l10n = context.l10n;
    final local = utc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat('h:mm a', locale).format(local);

    if (date == today) return l10n.jobTodayLabel(time);
    if (date == today.subtract(const Duration(days: 1))) {
      return l10n.jobYesterdayLabel;
    }
    return DateFormat('MMM d', locale).format(local);
  }

  String _languageName(AppLocalizations l10n, String code) => switch (code) {
    'ar' => l10n.languageArabic,
    'en' => l10n.languageEnglish,
    _ => code,
  };

  String _shortId(String id) =>
      id.length < 8 ? id : id.substring(0, 8);

  ({IconData icon, Color color, String label}) _sourceVisual(
    BuildContext context,
    JobSourceType type,
  ) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return switch (type) {
      JobSourceType.upload => (
        icon: Icons.graphic_eq_rounded,
        color: colors.primary,
        label: l10n.sourceAudioFile,
      ),
      JobSourceType.youtube => (
        icon: Icons.play_arrow_rounded,
        color: colors.statusFailed,
        label: l10n.sourceYoutube,
      ),
      JobSourceType.url => (
        icon: Icons.language_rounded,
        color: colors.sourceWeb,
        label: l10n.sourceWebUrl,
      ),
      JobSourceType.text => (
        icon: Icons.text_snippet_rounded,
        color: colors.primary,
        label: l10n.sourceText,
      ),
    };
  }

  ({Color color, Color background, String label}) _statusVisual(
    BuildContext context,
    JobStatus status,
  ) {
    final colors = context.appColors;
    final l10n = context.l10n;
    // Badge backgrounds are the status color at 12% opacity, matching the
    // Figma design exactly (e.g. rgba(5,150,105,0.12) for Done) rather than
    // the flat statusXBg tokens, which are different hex values.
    return switch (status) {
      JobStatus.done => (
        color: colors.statusDone,
        background: colors.statusDone.withValues(alpha: 0.12),
        label: l10n.statusDone,
      ),
      JobStatus.processing => (
        color: colors.primary,
        background: colors.primary.withValues(alpha: 0.12),
        label: l10n.statusProcessing,
      ),
      JobStatus.queued => (
        color: colors.statusQueued,
        background: colors.statusQueued.withValues(alpha: 0.12),
        label: l10n.statusQueued,
      ),
      JobStatus.failed => (
        color: colors.statusFailed,
        background: colors.statusFailed.withValues(alpha: 0.12),
        label: l10n.statusFailed,
      ),
      JobStatus.cancelled => (
        color: colors.statusCancelled,
        background: colors.statusCancelled.withValues(alpha: 0.12),
        label: l10n.statusCancelled,
      ),
    };
  }
}
