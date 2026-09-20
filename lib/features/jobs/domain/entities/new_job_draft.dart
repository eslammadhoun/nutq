import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/summarization/domain/entities/summary_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

/// Everything needed to create a job.
@immutable
class NewJobDraft {
  const NewJobDraft({
    required this.text,
    required this.language,
    this.length = SummaryLength.medium,
    this.sourceType = JobSourceType.text,
  });

  final String text;
  final SummaryLanguage language;
  final SummaryLength length;
  final JobSourceType sourceType;
}
