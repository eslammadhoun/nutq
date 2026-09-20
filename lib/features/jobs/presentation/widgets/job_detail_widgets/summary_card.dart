import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_tag_chip.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.job,
    this.streamingSummary,
    this.takeaways,
  });

  final JobDetailEntity job;

  /// Live word-by-word text from the `/jobs/{id}/ws` socket — takes
  /// precedence over `job.summary.summaryText` once the socket has
  /// streamed anything for this job.
  final String? streamingSummary;

  /// Takeaways carried by a `snapshot`/`done` WS frame for a job that was
  /// already terminal at connect time — `job.summary` itself is never
  /// populated by the WS path, so this is the only source for takeaways
  /// outside of a REST-fetched job. Takes precedence over
  /// `job.summary.takeaways` when present.
  final List<Map<String, dynamic>>? takeaways;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final summary = job.summary;
    final liveText = streamingSummary;
    final hasLiveText = liveText != null && liveText.isNotEmpty;
    final isStreaming =
        hasLiveText && (job.status == 'pending' || job.status == 'summarizing');
    final effectiveTakeaways = takeaways ?? summary?.takeaways ?? const [];

    return JobDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobDetailSectionHeader(
            glyph: '\u2728',
            title: l10n.jobDetailAiSummary,
            tag: summary == null
                ? null
                : JobDetailTagChip(
                    label: _toneLabel(summary.toneAndFormat),
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
          else ...[
            ExpandableJobText(
              hasLiveText ? liveText : (summary?.summaryText ?? ''),
              textDirection: job.language == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: context.typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              forceExpanded: isStreaming,
            ),
            if (effectiveTakeaways.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                l10n.jobDetailKeyTakeaways,
                style: context.typography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: 9.h),
              for (var i = 0; i < effectiveTakeaways.length; i++) ...[
                if (i > 0) SizedBox(height: 6.h),
                _takeaway(context, _takeawayText(effectiveTakeaways[i])),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _toneLabel(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// `takeaways` is an untyped JSONB list server-side — defensively pull a
  /// display string out of whichever key the backend used.
  String _takeawayText(Map<String, dynamic> takeaway) {
    final text =
        takeaway['text'] ??
        takeaway['title'] ??
        takeaway['label'] ??
        takeaway['message'];
    if (text is String && text.isNotEmpty) return text;
    return takeaway.values.whereType<String>().join(' ');
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
