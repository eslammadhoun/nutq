import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

part 'job_detail_entity.freezed.dart';

/// A job with its transcript and (once finished) its summary.
@freezed
sealed class JobDetailEntity with _$JobDetailEntity {
  const factory JobDetailEntity({
    required String id,
    required JobRunStatus status,
    required JobSourceType sourceType,
    required SummaryLanguage language,

    /// Length the summary was requested at.
    required SummaryLength requestedLength,
    required DateTime createdAt,
    required DateTime updatedAt,
    SummarizationFailureKind? failureKind,
    Transcript? transcript,
    Summary? summary,
  }) = _JobDetailEntity;
}
