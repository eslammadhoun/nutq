import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_tag_chip.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.job, this.streamingSummary});

  final JobDetailEntity job;

  /// The summary as it streams in; takes precedence over the stored summary
  /// until the job settles.
  final String? streamingSummary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final summary = job.summary;
    final liveText = streamingSummary;
    final hasLiveText = liveText != null && liveText.isNotEmpty;
    final isStreaming = hasLiveText && job.status.isActive;
    final takeaways = summary?.takeaways ?? const <String>[];

    return JobDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobDetailSectionHeader(
            glyph: '\u2728',
            title: l10n.jobDetailAiSummary,
            tag: summary == null
                ? null
                : JobDetailTagChip(
                    label: _toneLabel(summary.length.name),
                    background: colors.statusDoneBg,
                    foreground: colors.statusDone,
                  ),
          ),
          if (summary == null && !hasLiveText)
            Text(
              l10n.jobDetailSummaryPending,
              style: context.typography.captionSmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            Directionality(
              textDirection: jobTextDirection(job.language.code),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExpandableJobText(
                    hasLiveText ? liveText : (summary?.summaryText ?? ''),
                    textDirection: jobTextDirection(job.language.code),
                    style: context.typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    forceExpanded: isStreaming,
                  ),
                  if (takeaways.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      l10n.jobDetailKeyTakeaways,
                      style: context.typography.label.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 9.h),
                    for (var i = 0; i < takeaways.length; i++) ...[
                      if (i > 0) SizedBox(height: 6.h),
                      _takeaway(context, takeaways[i]),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _toneLabel(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Widget _takeaway(BuildContext context, String text) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 26.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: colors.statusProcessingBg,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Text(
        text,
        style: context.typography.caption.copyWith(color: colors.navIndicator),
      ),
    );
  }
}
