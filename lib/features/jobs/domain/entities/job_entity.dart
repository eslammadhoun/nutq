import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';

part 'job_entity.freezed.dart';

/// A job as shown in the list: lightweight, no transcript or summary bodies.
@freezed
sealed class JobEntity with _$JobEntity {
  const factory JobEntity({
    required String id,
    required JobRunStatus status,
    required JobSourceType sourceType,

    /// Language of the source (what is spoken or written).
    required ContentLanguage sourceLanguage,
    required DateTime createdAt,
    required DateTime updatedAt,

    /// First words of the transcript, for the list row.
    String? preview,

    /// Name of the file or video, when the source has one.
    String? sourceTitle,

    /// Why the job failed; only set when [status] is `failed`.
    JobFailureKind? failureKind,
  }) = _JobEntity;
}
