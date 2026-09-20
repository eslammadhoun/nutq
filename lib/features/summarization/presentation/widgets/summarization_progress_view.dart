import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/presentation/utils/summarization_labels.dart';

/// Progress with user-facing stage names only; no model/runtime details.
class SummarizationProgressView extends StatelessWidget {
  const SummarizationProgressView({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  final SummarizationProgress progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final processed = progress.processedChunks;
    final total = progress.totalChunks;
    final hasCount = processed != null && total != null && total > 0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220.w,
              child: LinearProgressIndicator(
                value: hasCount ? processed / total : null,
                minHeight: 6.h,
                borderRadius: BorderRadius.circular(4.r),
                color: colors.primary,
                backgroundColor: colors.borderSubtle,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              summarizationStageLabel(l10n, progress.stage),
              style: context.typography.heading5.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (hasCount) ...[
              SizedBox(height: 6.h),
              Text(
                l10n.summarizeChunkProgress(processed, total),
                style: context.typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
            SizedBox(height: 24.h),
            TextButton(onPressed: onCancel, child: Text(l10n.summarizeCancel)),
          ],
        ),
      ),
    );
  }
}
