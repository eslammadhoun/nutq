import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/expandable_job_text.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_section_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_detail_widgets/job_detail_tag_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class TranscriptCard extends StatelessWidget {
  const TranscriptCard({
    super.key,
    required this.job,
    this.transcriptText,
    this.isLoadingTranscriptText = false,
    this.streamingTranscript,
  });

  final JobDetailEntity job;

  /// Fetched separately from `transcript.downloadUrl` — the detail
  /// endpoint itself doesn't carry the transcript body.
  final String? transcriptText;
  final bool isLoadingTranscriptText;

  /// Live word-by-word text from the `/jobs/{id}/ws` socket — takes
  /// precedence over [transcriptText] once the socket has streamed
  /// anything for this job.
  final String? streamingTranscript;

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
              label: languageName(l10n, job.language),
              background: colors.statusProcessingBg,
              foreground: colors.textSecondary,
            ),
          ),
          // Streaming words can arrive before the transcript metadata frame
          // (or the REST payload) does — show the live body regardless of
          // whether [transcript] metadata has landed yet.
          if (transcript == null && (streamingTranscript?.isEmpty ?? true))
            Text(
              l10n.jobDetailTranscriptPending,
              style: context.typography.captionSmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            Directionality(
              textDirection: jobTextDirection(job.language),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (transcript != null) ...[
                    if (transcript.modelName.isNotEmpty ||
                        transcript.modelVersion.isNotEmpty) ...[
                      Text(
                        '${transcript.modelName} · ${transcript.modelVersion}'
                        '${transcript.quantization != null ? ' · ${transcript.quantization}' : ''}',
                        style: context.typography.captionSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                    Text(
                      [
                        if (transcript.durationSeconds != null)
                          formatDuration(transcript.durationSeconds!),
                        if (transcript.wordCount != null)
                          l10n.jobDetailWordCount(transcript.wordCount!),
                      ].join(' · '),
                      style: context.typography.captionSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 11.h),
                  ],
                  _transcriptBody(context),
                  if (transcript?.downloadUrl != null) ...[
                    SizedBox(height: 6.h),
                    _downloadButton(context, transcript!.downloadUrl!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _transcriptBody(BuildContext context) {
    final colors = context.appColors;
    final liveText = streamingTranscript;

    if (liveText != null && liveText.isNotEmpty) {
      return ExpandableJobText(
        liveText,
        textDirection: jobTextDirection(job.language),
        style: context.typography.bodyBase.copyWith(color: colors.textPrimary),
      );
    }

    if (isLoadingTranscriptText) {
      return SizedBox(
        height: 16.h,
        width: 16.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textSecondary,
        ),
      );
    }

    if (transcriptText == null) {
      return Text(
        context.l10n.jobDetailTranscriptPending,
        style: context.typography.captionSmall.copyWith(
          color: colors.textSecondary,
        ),
      );
    }

    return ExpandableJobText(
      transcriptText!,
      textDirection: jobTextDirection(job.language),
      style: context.typography.bodyBase.copyWith(color: colors.textPrimary),
    );
  }

  Widget _downloadButton(BuildContext context, String downloadUrl) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => launchUrl(Uri.parse(downloadUrl)),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: colors.statusProcessingBg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: colors.navIndicator),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: 16.sp,
              color: colors.navIndicator,
            ),
            SizedBox(width: 8.w),
            Text(
              context.l10n.jobDetailDownloadTranscript,
              style: context.typography.labelXS.copyWith(
                color: colors.navIndicator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
