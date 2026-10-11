import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';

/// A finished job, shown in Alerts: one per completed or failed job.
@immutable
class JobAlert {
  const JobAlert({
    required this.jobId,
    required this.title,
    required this.at,
    this.failure,
  });

  final String jobId;

  /// The job's file name, or the start of its text.
  final String title;

  /// When the job finished.
  final DateTime at;

  /// Why it failed; null for a completed job.
  final JobFailureKind? failure;

  bool get succeeded => failure == null;

  @override
  bool operator ==(Object other) =>
      other is JobAlert &&
      other.jobId == jobId &&
      other.title == title &&
      other.at == at &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(jobId, title, at, failure);
}
