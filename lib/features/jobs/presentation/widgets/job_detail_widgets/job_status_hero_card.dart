import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/l10n/app_localizations.dart';

class JobStatusHeroCard extends StatelessWidget {
  const JobStatusHeroCard({super.key, required this.job});

  final JobDetailEntity job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final status = Job.statusFromRaw(job.status);
    final source = sourceTypeVisual(
      context,
      Job.sourceTypeFromRaw(job.sourceType),
      isVideoUpload:
          job.sourceType == 'upload' && (job.contentType?.startsWith('video/') ?? false),
    );
    final transcript = job.transcript;

    final metaParts = [
      source.label,
      languageName(l10n, job.language),
      if (transcript?.durationSeconds != null)
        formatDuration(transcript!.durationSeconds!),
      if (transcript?.wordCount != null)
        l10n.jobDetailWordCount(transcript!.wordCount!),
    ];

    return Container(
      width: double.infinity,
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
              color: colors.textInverse.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(source.icon, size: 18.sp, color: colors.textInverse),
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
                  metaParts.join(' · '),
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
                if (status == JobStatus.failed && job.errorDetail != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    job.errorDetail!,
                    style: context.typography.captionSmall.copyWith(
                      color: colors.textInverse.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _headline(AppLocalizations l10n, JobStatus status, String sourceType) => switch (status) {
    JobStatus.done => sourceType == 'text' ? l10n.jobDetailSummaryComplete : l10n.jobDetailTranscriptionComplete,
    JobStatus.processing => l10n.statusProcessing,
    JobStatus.queued => l10n.statusQueued,
    JobStatus.failed => l10n.statusFailed,
    JobStatus.cancelled => l10n.statusCancelled,
  };

  Widget _statusBadge(BuildContext context, JobStatus status) {
    final colors = context.appColors;
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: colors.textInverse.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: colors.textInverse,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            jobStatusVisual(context, status).label,
            style: context.typography.label.copyWith(color: colors.textInverse),
          ),
        ],
      ),
    );
  }
}
