import 'dart:async';

import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/source_transcript.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';

/// A scripted stand-in for a media source (audio, video, YouTube): reports a
/// download and a transcription phase, records what it was asked, and returns
/// (or throws) whatever the test decides.
class FakeMediaSource implements TranscriptSource {
  FakeMediaSource({
    this.type = JobSourceType.audio,
    this.progressShare = 0.4,
    this.text = 'نص مفرّغ من ملف صوتي عن الميزانية والخطة',
    this.error,
    this.info,
    this.gate,
  });

  @override
  final JobSourceType type;

  @override
  final double progressShare;

  final String text;

  /// Thrown from [resolve] after progress was reported.
  final Object? error;

  /// Reported through `saveSourceInfo` while working.
  final SourceInfo? info;

  /// When set, [resolve] waits here between its two phases.
  final Completer<void>? gate;

  int resolveCalls = 0;

  @override
  Future<SourceTranscript> resolve(SourceRequest request) async {
    resolveCalls++;
    request.onProgress(const JobProgress(JobStage.acquiring, fraction: 0.5));
    if (info != null) await request.saveSourceInfo(info!);
    request.onProgress(const JobProgress(JobStage.acquiring, fraction: 1));
    if (gate != null) await gate!.future;
    request.cancellation.throwIfCancelled();
    request.onProgress(const JobProgress(JobStage.transcribing, fraction: 0.5));
    if (error != null) throw error!;
    request.onProgress(const JobProgress(JobStage.transcribing, fraction: 1));
    return SourceTranscript(text, modelName: 'fake-asr', modelVersion: '1');
  }
}
