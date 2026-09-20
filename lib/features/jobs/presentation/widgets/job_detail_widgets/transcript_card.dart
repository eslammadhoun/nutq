import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_tag_chip.dart';

class TranscriptCard extends StatelessWidget {
  const TranscriptCard({super.key, required this.job});

  final JobDetailEntity job;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final transcript = job.transcript;

    return JobDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobDetailSectionHeader(
            glyph: '\u{1F4C4}',
            title: l10n.jobDetailTranscript,
            tag: JobDetailTagChip(
              label: languageName(l10n, job.sourceLanguage.code),
              background: colors.statusProcessingBg,
              foreground: colors.textSecondary,
            ),
          ),
          if (transcript == null)
            Text(
              l10n.jobDetailTranscriptPending,
              style: context.typography.captionSmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            Directionality(
              textDirection: jobTextDirection(job.sourceLanguage.code),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if ((transcript.modelName?.isNotEmpty ?? false) ||
                      (transcript.modelVersion?.isNotEmpty ?? false)) ...[
                    Text(
                      [
                        transcript.modelName,
                        transcript.modelVersion,
                      ].whereType<String>().where((p) => p.isNotEmpty).join(' · '),
                      style: context.typography.captionSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 5.h),
                  ],
                  Text(
                    [
                      if (job.durationSeconds != null) formatDuration(job.durationSeconds!),
                      l10n.jobDetailWordCount(transcript.wordCount),
                    ].join(' · '),
                    style: context.typography.captionSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 11.h),
                  _transcriptBody(context, transcript.text),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _transcriptBody(BuildContext context, String text) {
    return ExpandableJobText(
      text,
      textDirection: jobTextDirection(job.sourceLanguage.code),
      style: context.typography.bodyBase.copyWith(
        color: context.appColors.textPrimary,
      ),
    );
  }
}
