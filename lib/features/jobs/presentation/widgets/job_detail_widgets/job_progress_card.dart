import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/presentation/utils/summarization_labels.dart';

/// Live progress of the running summary job: current stage, overall bar and
/// processed/total sections. Rebuilds on every event of the progress stream.
class JobProgressCard extends StatelessWidget {
  const JobProgressCard({super.key, required this.progress});

  final SummarizationProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final processed = progress.processedChunks;
    final total = progress.totalChunks;
    final hasCount = processed != null && total != null && total > 0;
    final percent = (progress.fraction * 100).round();

    return JobDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.statusProcessing),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  summarizationStageLabel(l10n, progress.stage),
                  style: context.typography.labelMedium.copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                '$percent%',
                style: context.typography.label.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.fraction),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6.h,
              borderRadius: BorderRadius.circular(4.r),
              color: colors.statusProcessing,
              backgroundColor: colors.statusProcessingBg,
            ),
          ),
          if (hasCount) ...[
            SizedBox(height: 8.h),
            Text(
              l10n.summarizeChunkProgress(processed, total),
              style: context.typography.captionSmall.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
