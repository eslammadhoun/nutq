import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final source = sourceTypeVisual(context, job.sourceType);
    final status = jobStatusVisual(context, job.status);

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
              job.preview ?? l10n.jobFallbackTitle(_shortId(job.id)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${formatJobTimestamp(context, job.createdAt)} · ${languageName(l10n, job.languageCode)}',
              style: context.typography.captionSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) => id.length < 8 ? id : id.substring(0, 8);
}
