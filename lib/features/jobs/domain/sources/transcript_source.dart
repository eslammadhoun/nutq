import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/source_transcript.dart';

/// What a source needs while it works.
class SourceRequest {
  const SourceRequest({
    required this.job,
    required this.onProgress,
    required this.cancellation,
    required this.saveSourceInfo,
  });

  final JobDetailEntity job;

  /// Report progress of the source's own work. `fraction` is 0.0–1.0 within
  /// that work; the processor maps it onto the whole job's progress bar.
  final void Function(JobProgress progress) onProgress;

  /// Check between steps (and pass to long operations) so cancelling is prompt.
  final CancellationToken cancellation;

  /// Persist what was learned about the source (title, downloaded file,
  /// duration) as soon as it is known.
  final Future<void> Function(SourceInfo info) saveSourceInfo;
}

/// Turns a job's input into the transcript text that gets summarized.
///
/// One implementation per [JobSourceType]: pasted text just returns what is
/// stored; a YouTube source would download and transcribe; an audio source would
/// transcribe the file. Throw `JobFailure` to fail the job with a specific
/// reason and `CancelledException` when cancelled.
abstract interface class TranscriptSource {
  JobSourceType get type;

  /// The share of the job's progress bar (0.0–1.0) spent in [resolve]; the
  /// rest is summarization. Pasted text has none.
  double get progressShare;

  Future<SourceTranscript> resolve(SourceRequest request);
}
