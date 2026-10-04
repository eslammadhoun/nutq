import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/source_transcript.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';

/// Pasted text: the transcript is already stored with the job.
class TextTranscriptSource implements TranscriptSource {
  const TextTranscriptSource();

  @override
  JobSourceType get type => JobSourceType.text;

  @override
  double get progressShare => 0;

  @override
  Future<SourceTranscript> resolve(SourceRequest request) async {
    final text = request.job.transcript?.text;
    if (text == null || text.trim().isEmpty) {
      throw const JobFailure(JobFailureKind.emptyTranscript);
    }
    return SourceTranscript(text);
  }
}
