import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

/// Everything needed to create a job. Use the named constructors: each one
/// carries exactly the fields its source type needs.
@immutable
class NewJobDraft {
  const NewJobDraft._({
    required this.sourceType,
    required this.sourceLanguage,
    required this.summaryLanguage,
    required this.length,
    this.text,
    this.sourceUrl,
    this.sourceFilePath,
    this.sourceMimeType,
    this.sourceTitle,
    this.durationSeconds,
  });

  /// Pasted text. The summary is written in [language] unless
  /// [summaryLanguage] says otherwise.
  factory NewJobDraft.text({
    required String text,
    required ContentLanguage language,
    ContentLanguage? summaryLanguage,
    SummaryLength length = SummaryLength.medium,
  }) => NewJobDraft._(
    sourceType: JobSourceType.text,
    sourceLanguage: language,
    summaryLanguage: summaryLanguage ?? language,
    length: length,
    text: text,
  );

  /// A YouTube video, identified by its web address.
  factory NewJobDraft.youtube({
    required String url,
    required ContentLanguage language,
    ContentLanguage? summaryLanguage,
    SummaryLength length = SummaryLength.medium,
    String? title,
  }) => NewJobDraft._(
    sourceType: JobSourceType.youtube,
    sourceLanguage: language,
    summaryLanguage: summaryLanguage ?? language,
    length: length,
    sourceUrl: url,
    sourceTitle: title,
  );

  /// An audio or video file already copied into app storage.
  factory NewJobDraft.media({
    required JobSourceType type,
    required String filePath,
    required ContentLanguage language,
    ContentLanguage? summaryLanguage,
    SummaryLength length = SummaryLength.medium,
    String? mimeType,
    String? title,
    double? durationSeconds,
  }) {
    assert(
      type == JobSourceType.audio || type == JobSourceType.video,
      'media drafts are audio or video, got $type',
    );
    return NewJobDraft._(
      sourceType: type,
      sourceLanguage: language,
      summaryLanguage: summaryLanguage ?? language,
      length: length,
      sourceFilePath: filePath,
      sourceMimeType: mimeType,
      sourceTitle: title,
      durationSeconds: durationSeconds,
    );
  }

  final JobSourceType sourceType;
  final ContentLanguage sourceLanguage;
  final ContentLanguage summaryLanguage;
  final SummaryLength length;
  final String? text;
  final String? sourceUrl;
  final String? sourceFilePath;
  final String? sourceMimeType;
  final String? sourceTitle;
  final double? durationSeconds;
}
