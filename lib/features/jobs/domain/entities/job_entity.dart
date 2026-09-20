import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/core/domain/content_language.dart';

part 'job_entity.freezed.dart';

/// A job as shown in the list: lightweight, no transcript or summary bodies.
@freezed
sealed class JobEntity with _$JobEntity {
  const factory JobEntity({
    required String id,
    required JobRunStatus status,
    required JobSourceType sourceType,
    required ContentLanguage language,
    required DateTime createdAt,
    required DateTime updatedAt,

    /// First words of the transcript, for the list row.
    String? preview,

    /// Why the job failed; only set when [status] is `failed`.
    JobFailureKind? failureKind,
  }) = _JobEntity;
}
