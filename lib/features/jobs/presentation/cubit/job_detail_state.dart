import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';

enum JobDetailStatus { loading, success, notFound, failure }

@immutable
class JobDetailState {
  const JobDetailState({
    this.status = JobDetailStatus.loading,
    this.job,
    this.lastError,
    this.isCancelling = false,
    this.progress,
    this.streamingSummary,
  });

  final JobDetailStatus status;

  /// The stored job — the durable truth, updated whenever the database changes.
  final JobDetailEntity? job;

  /// Raw error from a failed load — localized at display time.
  final ApiError? lastError;

  final bool isCancelling;

  /// Live pipeline progress while the job runs. In-memory only: never stored.
  final SummarizationProgress? progress;

  /// The summary as it is being generated, word by word. Cleared once the job
  /// settles; the stored summary takes over.
  final String? streamingSummary;

  JobDetailState copyWith({
    JobDetailStatus? status,
    JobDetailEntity? job,
    ApiError? lastError,
    bool clearLastError = false,
    bool? isCancelling,
    SummarizationProgress? progress,
    String? streamingSummary,
    bool clearLive = false,
  }) => JobDetailState(
    status: status ?? this.status,
    job: job ?? this.job,
    lastError: clearLastError ? null : (lastError ?? this.lastError),
    isCancelling: isCancelling ?? this.isCancelling,
    progress: clearLive ? null : (progress ?? this.progress),
    streamingSummary: clearLive
        ? null
        : (streamingSummary ?? this.streamingSummary),
  );
}
