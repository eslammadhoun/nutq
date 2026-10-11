import 'dart:async';
import 'dart:io';

import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/source_transcript.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';

/// An audio or video file in app storage: extract its audio, then transcribe
/// it on the device in the job's source language.
///
/// The lock screen's play/pause button ([BackgroundJob.commands]) pauses
/// recognition. Showing the job there is `ProcessJob`'s work.
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

  @override
  bool get transcribesAudio => true;

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

    final audio = await _extract(path, request);
    try {
      return await _transcribe(audio, request);
    } finally {
      await audio.delete();
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

    final stopRecognition = request.cancellation.onCancel(_recognizer.cancel);
    // Lock-screen play/pause. Recognition stops after the chunk in flight.
    final commands = _background.commands.listen((command) {
      // Cancel is handled for the whole job by ProcessJob.
      if (command == BackgroundJobCommand.cancel) return;
      final paused = command == BackgroundJobCommand.pause;
      unawaited(paused ? _recognizer.pause() : _recognizer.resume());
      unawaited(_background.setPaused(paused));
    });
    try {
      final speech = await _recognizer.transcribe(
        audioPath: audio.path,
        language: request.job.sourceLanguage,
        onPartialText: request.onPartialTranscript,
        onProgress: (fraction) => request.onProgress(
          JobProgress(
            JobStage.transcribing,
            fraction: extractionShare + (1 - extractionShare) * fraction,
          ),
        ),
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
