import 'package:nutq/features/jobs/data/models/job_response.dart';

enum JobStatus { done, processing, queued, failed, cancelled }

enum JobSourceType { upload, youtube, url, text }

/// UI-facing view of a [JobResponse].
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

  factory Job.fromResponse(JobResponse response) {
    final status = _statusFromRaw(response.status);
    return Job(
      id: response.id,
      // The list endpoint has no title/preview; only failed jobs carry a
      // server-provided error detail worth showing as the subtitle.
      subtitle:
          status == JobStatus.failed && response.errorDetail != null
              ? response.errorDetail!
              : null,
      sourceType: _sourceTypeFromRaw(response.sourceType),
      status: status,
      createdAt: response.createdAt,
      languageCode: response.language,
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
