import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/l10n/app_localizations.dart';

class JobStatusHeroCard extends StatelessWidget {
  const JobStatusHeroCard({super.key, required this.job});

  final JobDetailEntity job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final status = job.status;
    final source = sourceTypeVisual(context, job.sourceType);
    final transcript = job.transcript;

    final metaParts = [
      source.label,
      languageName(l10n, job.language.code),
      if (transcript?.durationSeconds != null)
        formatDuration(transcript!.durationSeconds!),
      if (transcript != null) l10n.jobDetailWordCount(transcript.wordCount),
    ];

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 132.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [colors.heroGradientStart, colors.heroGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.textInverse,
              shape: BoxShape.circle,
            ),
            child: Icon(source.icon, size: 18.sp, color: colors.textSecondary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _headline(l10n, status, job.sourceType),
                        style: context.typography.labelLarge.copyWith(
                          color: colors.textInverse,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _statusBadge(context, status),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  metaParts.join('  ·  '),
                  style: context.typography.bodySmall.copyWith(
                    color: colors.textInverse.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formatJobDetailTimestamp(context, job.createdAt),
                  style: context.typography.caption.copyWith(
                    color: colors.textInverse.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _headline(
    AppLocalizations l10n,
    JobRunStatus status,
    JobSourceType sourceType,
  ) => switch (status) {
    JobRunStatus.completed =>
      sourceType == JobSourceType.text
          ? l10n.jobDetailSummaryComplete
          : l10n.jobDetailTranscriptionComplete,
    JobRunStatus.running => l10n.statusProcessing,
    JobRunStatus.pending => l10n.statusQueued,
    JobRunStatus.failed => l10n.statusFailed,
    JobRunStatus.cancelled => l10n.statusCancelled,
  };

  Widget _statusBadge(BuildContext context, JobRunStatus status) {
    final colors = context.appColors;
    final visual = jobStatusVisual(context, status);
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: colors.textInverse,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: visual.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            visual.label,
            style: context.typography.label.copyWith(color: visual.color),
          ),
        ],
      ),
    );
  }
}
