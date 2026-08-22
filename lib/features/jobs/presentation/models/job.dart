enum JobStatus { done, processing, queued, failed, cancelled }

enum JobSourceType { upload, youtube, url, text }

class Job {
  const Job({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.status,
    required this.timestampLabel,
    required this.language,
  });

  final String id;
  final String title;
  final JobSourceType sourceType;
  final JobStatus status;
  final String timestampLabel;
  final String language;
}
