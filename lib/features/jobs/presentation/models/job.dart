import 'package:nutq/features/jobs/data/models/job_response.dart';

enum JobStatus { done, processing, queued, failed, cancelled }

enum JobSourceType { upload, youtube, url, text }

/// UI-facing view of a [JobResponse].
///
/// The list endpoint doesn't return a title/preview (that only exists once
/// a transcript/summary is generated, via GET /jobs/{id}) — [subtitle] is a
/// best-effort fallback: the error detail for failed jobs, otherwise a short
/// job id, never fabricated content.
class Job {
  const Job({
    required this.id,
    required this.subtitle,
    required this.sourceType,
    required this.status,
    required this.timestampLabel,
    required this.language,
  });

  factory Job.fromResponse(JobResponse response) {
    final status = _statusFromRaw(response.status);
    return Job(
      id: response.id,
      subtitle: status == JobStatus.failed && response.errorDetail != null
          ? response.errorDetail!
          : 'Job #${response.id.substring(0, response.id.length < 8 ? response.id.length : 8)}',
      sourceType: _sourceTypeFromRaw(response.sourceType),
      status: status,
      timestampLabel: _formatTimestamp(response.createdAt),
      language: _languageName(response.language),
    );
  }

  final String id;
  final String subtitle;
  final JobSourceType sourceType;
  final JobStatus status;
  final String timestampLabel;
  final String language;

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

  static String _languageName(String code) {
    const names = {'ar': 'Arabic', 'en': 'English'};
    return names[code] ?? code;
  }

  static String _formatTimestamp(DateTime utc) {
    final local = utc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    if (date == today) return 'Today, $time';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}';
  }
}
