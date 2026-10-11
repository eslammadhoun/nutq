import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/core/widgets/app_icon.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_tag_chip.dart';

class TranscriptCard extends StatelessWidget {
  const TranscriptCard({super.key, required this.job, this.streamingTranscript});

  final JobDetailEntity job;

  /// The transcript as it is being recognized, shown until the stored one
  /// exists.
  final String? streamingTranscript;

  /// Lines of a live transcript on screen: the newest, like captions. Laying
  /// out an hour of text on every update would stall the UI, and the whole
  /// transcript is shown once it is stored.
  static const liveLines = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final transcript = job.transcript;
    final live = streamingTranscript;
    final isLive = transcript == null && live != null && live.isNotEmpty;

    return JobDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobDetailSectionHeader(
            iconPath: AppIcons.transcript,
            title: l10n.jobDetailTranscript,
            tag: JobDetailTagChip(
              label: languageName(l10n, job.sourceLanguage.code),
              background: colors.statusProcessingBg,
              foreground: colors.textSecondary,
            ),
          ),
          if (isLive)
            _liveBody(context, live)
          else if (transcript == null)
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

  Widget _liveBody(BuildContext context, String text) {
    final colors = context.appColors;
    final lines = text.split('\n');
    final shown = lines.length > liveLines ? lines.sublist(lines.length - liveLines) : lines;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return Directionality(
      textDirection: jobTextDirection(job.sourceLanguage.code),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${context.l10n.jobDetailTranscriptLive} · ${context.l10n.jobDetailWordCount(words)}',
            style: context.typography.captionSmall.copyWith(color: colors.statusProcessing),
          ),
          SizedBox(height: 11.h),
          Text(
            [if (shown.length < lines.length) '…', ...shown].join('\n'),
            style: context.typography.bodyBase.copyWith(color: colors.textPrimary),
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
