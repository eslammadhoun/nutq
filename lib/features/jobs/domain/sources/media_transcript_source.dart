import 'dart:async';
import 'dart:io';

import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/source_transcript.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/features/transcription/domain/background_job.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';

/// An audio or video file in app storage: extract its audio, then transcribe
/// it on the device in the job's source language.
///
/// While it works, [BackgroundJob] keeps the app running when the user leaves
/// it and shows the progress on the lock screen, whose play/pause button
/// pauses recognition.
class MediaTranscriptSource implements TranscriptSource {
  const MediaTranscriptSource({
    required this.type,
    required this._extractor,
    required this._recognizer,
    this._background = const NoBackgroundJob(),
  }) : assert(
         type == JobSourceType.audio || type == JobSourceType.video,
         'media sources are audio or video, got $type',
       );

  @override
  final JobSourceType type;

  final AudioExtractor _extractor;
  final SpeechRecognizer _recognizer;
  final BackgroundJob _background;

  /// Transcription runs at roughly a tenth of real time on an iPhone XR, and
  /// summarizing the result takes about as long again.
  @override
  double get progressShare => 0.5;

  /// The share of this source's work spent extracting audio; the rest is
  /// recognition.
  static const extractionShare = 0.1;

  @override
  Future<SourceTranscript> resolve(SourceRequest request) async {
    final path = request.job.sourceFilePath;
    if (path == null || !File(path).existsSync()) {
      throw JobFailure(JobFailureKind.sourceUnavailable, 'missing file: $path');
    }

    // One job runs at a time, so any extracted audio on disk was left behind
    // by a run that never finished.
    await _extractor.deleteLeftovers();
    request.cancellation.throwIfCancelled();
    request.onProgress(const JobProgress(JobStage.acquiring, fraction: 0));

    await _background.begin(title: request.job.sourceTitle ?? path.split('/').last);
    var completed = false;
    try {
      final audio = await _extract(path, request);
      try {
        final transcript = await _transcribe(audio, request);
        completed = true;
        return transcript;
      } finally {
        await audio.delete();
      }
    } finally {
      await _background.end(completed: completed);
    }
  }

  Future<ExtractedAudio> _extract(String path, SourceRequest request) async {
    final stopExtraction = request.cancellation.onCancel(_extractor.cancel);
    try {
      return await _extractor.extract(path);
    } on AudioExtractionException catch (e) {
      throw JobFailure(JobFailureKind.unsupportedMedia, e.message);
    } on FileSystemException catch (e) {
      throw JobFailure(JobFailureKind.insufficientStorage, e.message);
    } finally {
      stopExtraction();
    }
  }

  Future<SourceTranscript> _transcribe(ExtractedAudio audio, SourceRequest request) async {
    request.cancellation.throwIfCancelled();
    await request.saveSourceInfo(SourceInfo(durationSeconds: audio.duration.inMilliseconds / 1000));
    request.onProgress(const JobProgress(JobStage.acquiring, fraction: extractionShare));
    await _background.update(progress: 0, duration: audio.duration);

    final stopRecognition = request.cancellation.onCancel(_recognizer.cancel);
    // Lock-screen play/pause. Recognition stops after the chunk in flight.
    final commands = _background.commands.listen((command) {
      final paused = command == BackgroundJobCommand.pause;
      unawaited(paused ? _recognizer.pause() : _recognizer.resume());
      unawaited(_background.setPaused(paused));
    });
    try {
      final speech = await _recognizer.transcribe(
        audioPath: audio.path,
        language: request.job.sourceLanguage,
        onProgress: (fraction) {
          request.onProgress(
            JobProgress(
              JobStage.transcribing,
              fraction: extractionShare + (1 - extractionShare) * fraction,
            ),
          );
          // The lock-screen timeline spans the audio, not the whole job.
          unawaited(_background.update(progress: fraction));
        },
      );
      request.cancellation.throwIfCancelled();
      return SourceTranscript(
        speech.text,
        modelName: speech.modelName,
        modelVersion: speech.modelVersion,
      );
    } on SpeechRecognitionException catch (e) {
      throw JobFailure(JobFailureKind.transcriptionFailed, e.message);
    } finally {
      await commands.cancel();
      stopRecognition();
    }
  }
}
