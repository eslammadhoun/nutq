import 'package:nutq/features/jobs/domain/entities/job_entity.dart';

enum JobStatus { done, processing, queued, failed, cancelled }

enum JobSourceType { upload, youtube, url, text }

/// UI-facing view of a [JobEntity].
///
/// Deliberately free of display strings (dates, language names, titles):
/// those are locale-dependent, and this model is built inside the cubit
/// where no BuildContext exists. [JobCard] formats everything via l10n.
class Job {
  const Job({
    required this.id,
    required this.subtitle,
    required this.sourceType,
    required this.status,
    required this.createdAt,
    required this.languageCode,
  });

  factory Job.fromEntity(JobEntity entity) {
    final status = _statusFromRaw(entity.status);
    return Job(
      id: entity.id,
      // The list endpoint has no title/preview; only failed jobs carry a
      // server-provided error detail worth showing as the subtitle.
      subtitle:
          status == JobStatus.failed && entity.errorDetail != null
              ? entity.errorDetail!
              : null,
      sourceType: _sourceTypeFromRaw(entity.sourceType),
      status: status,
      createdAt: entity.createdAt,
      languageCode: entity.language,
    );
  }

  final String id;

  /// Server-provided error detail (failed jobs only), otherwise null.
  final String? subtitle;
  final JobSourceType sourceType;
  final JobStatus status;
  final DateTime createdAt;
  final String languageCode;

  static JobStatus _statusFromRaw(String raw) {
    switch (raw) {
      case 'completed':
        return JobStatus.done;
      case 'failed':
        return JobStatus.failed;
      case 'cancelled':
        return JobStatus.cancelled;
      case 'pending':
        return JobStatus.queued;
      default:
        // uploaded / extracting / transcribing / restoring / chunking /
        // summarizing / clipping — all in-flight processing stages.
        return JobStatus.processing;
    }
  }

  static JobSourceType _sourceTypeFromRaw(String raw) {
    return JobSourceType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => JobSourceType.text,
    );
  }
}
