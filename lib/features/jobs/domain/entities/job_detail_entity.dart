import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

part 'job_detail_entity.freezed.dart';

/// A job with its source description, transcript and (once finished) summary.
@freezed
sealed class JobDetailEntity with _$JobDetailEntity {
  const factory JobDetailEntity({
    required String id,
    required JobRunStatus status,
    required JobSourceType sourceType,

    /// Language of the source (what is spoken or written).
    required ContentLanguage sourceLanguage,

    /// Language the summary is written in.
    required ContentLanguage summaryLanguage,

    /// Length the summary was requested at.
    required SummaryLength requestedLength,
    required DateTime createdAt,
    required DateTime updatedAt,
    JobFailureKind? failureKind,

    /// The web address of the source (YouTube).
    String? sourceUrl,

    /// The app-owned copy of an uploaded file. Deleted with the job.
    String? sourceFilePath,
    String? sourceMimeType,

    /// Name of the file or video.
    String? sourceTitle,

    /// Length of the audio/video, once known.
    double? durationSeconds,

    /// Null until the job has one (pasted text has it from the start; media
    /// gets it once transcribed).
    Transcript? transcript,
    Summary? summary,
  }) = _JobDetailEntity;
}
