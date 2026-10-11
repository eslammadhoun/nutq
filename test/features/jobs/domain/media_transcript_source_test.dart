import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_progress.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/features/jobs/domain/sources/media_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';

class _FakeExtractor implements AudioExtractor {
  _FakeExtractor(this.dir);

  final Directory dir;
  Object? error;
  Completer<void>? gate;
  int cancels = 0;
  int leftoverSweeps = 0;
  ExtractedAudio? produced;

  @override
  Future<ExtractedAudio> extract(String inputPath) async {
    if (gate != null) await gate!.future;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (error != null) throw error!;
    final wav = File('${dir.path}/extracted.wav')..writeAsBytesSync([0]);
    return produced = ExtractedAudio(path: wav.path, duration: const Duration(seconds: 90));
  }

  @override
  Future<void> cancel() async => cancels++;

  @override
  Future<void> deleteLeftovers() async => leftoverSweeps++;
}

class _FakeRecognizer implements SpeechRecognizer {
  Object? error;
  Completer<void>? gate;
  ContentLanguage? language;
  int cancels = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<RecognizedSpeech> transcribe({
    required String audioPath,
    required ContentLanguage language,
    void Function(double progress)? onProgress,
    void Function(String text)? onPartialText,
  }) async {
    this.language = language;
    onProgress?.call(0.5);
    onPartialText?.call('السطر الأول');
    if (gate != null) await gate!.future;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (error != null) throw error!;
    onProgress?.call(1);
    return const RecognizedSpeech(
      text: 'السطر الأول\nالسطر الثاني',
      modelName: 'moonshine-tiny-streaming-ar',
      modelVersion: 'v1',
    );
  }

  @override
  Future<void> cancel() async => cancels++;

  final pauses = <bool>[];

  @override
  Future<void> pause() async => pauses.add(true);

  @override
  Future<void> resume() async => pauses.add(false);
}

/// Records what the source shows outside the app, and lets a test press the
/// lock-screen buttons.
class _FakeBackgroundJob implements BackgroundJob {
  final calls = <String>[];
  final _commands = StreamController<BackgroundJobCommand>.broadcast();

  void press(BackgroundJobCommand command) => _commands.add(command);

  @override
  Stream<BackgroundJobCommand> get commands => _commands.stream;

  @override
  Future<void> begin({required String title}) async => calls.add('begin $title');

  @override
  Future<void> update({required double progress, Duration? estimatedTotal}) async =>
      calls.add('update $progress');

  @override
  Future<void> setPhase(BackgroundJobPhase phase) async => calls.add('phase ${phase.name}');

  @override
  Future<void> setPaused(bool paused) async => calls.add('paused $paused');

  @override
  Future<void> end({required bool completed}) async => calls.add('end $completed');
}

void main() {
  late Directory dir;
  late File media;
  late _FakeExtractor extractor;
  late _FakeRecognizer recognizer;
  late _FakeBackgroundJob background;
  late MediaTranscriptSource source;
  late List<JobProgress> progress;
  late List<SourceInfo> saved;
  late CancellationToken token;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('media_source_test');
    media = File('${dir.path}/talk.m4a')..writeAsBytesSync([1, 2, 3]);
    extractor = _FakeExtractor(dir);
    recognizer = _FakeRecognizer();
    background = _FakeBackgroundJob();
    source = MediaTranscriptSource(
      type: JobSourceType.audio,
      extractor: extractor,
      recognizer: recognizer,
      background: background,
    );
    progress = [];
    saved = [];
    token = CancellationToken();
  });
  tearDown(() => dir.deleteSync(recursive: true));

  JobDetailEntity job({String? path, ContentLanguage language = ContentLanguage.ar}) =>
      JobDetailEntity(
        id: 'job-1',
        status: JobRunStatus.running,
        sourceType: JobSourceType.audio,
        sourceLanguage: language,
        summaryLanguage: language,
        requestedLength: SummaryLength.medium,
        createdAt: DateTime.utc(2026, 10),
        updatedAt: DateTime.utc(2026, 10),
        sourceFilePath: path ?? media.path,
        sourceTitle: 'talk.m4a',
      );

  late List<String> partials;

  Future<String> resolve([JobDetailEntity? j]) async {
    partials = [];
    final result = await source.resolve(
      SourceRequest(
        job: j ?? job(),
        onProgress: progress.add,
        onPartialTranscript: partials.add,
        cancellation: token,
        saveSourceInfo: (info) async => saved.add(info),
      ),
    );
    return result.text;
  }

  Future<JobFailureKind> failureOf(Future<Object?> future) async {
    try {
      await future;
    } on JobFailure catch (f) {
      return f.kind;
    }
    fail('expected a JobFailure');
  }

  test('extracts, transcribes in the job language, and returns the text', () async {
    expect(await resolve(job(language: ContentLanguage.en)), 'السطر الأول\nالسطر الثاني');
    expect(recognizer.language, ContentLanguage.en);
    expect(partials, ['السطر الأول'], reason: 'live text is passed on as it is recognized');
    expect(extractor.leftoverSweeps, 1);
  });

  test(
    'records the duration and reports monotonic progress from acquiring to transcribing',
    () async {
      await resolve();
      expect(saved.single.durationSeconds, 90);
      final fractions = progress.map((p) => p.fraction).toList();
      expect(fractions, orderedEquals([...fractions]..sort()));
      expect(progress.first.stage, JobStage.acquiring);
      expect(progress.last, const JobProgress(JobStage.transcribing, fraction: 1));
    },
  );

  test('deletes the extracted audio whether it succeeds or fails', () async {
    await resolve();
    expect(File(extractor.produced!.path).existsSync(), isFalse);

    recognizer.error = const SpeechRecognitionException('boom');
    await failureOf(resolve());
    expect(File(extractor.produced!.path).existsSync(), isFalse);
  });

  test('a missing source file fails as unavailable', () async {
    expect(
      await failureOf(resolve(job(path: '${dir.path}/gone.mp3'))),
      JobFailureKind.sourceUnavailable,
    );
  });

  test('unreadable media fails as unsupported', () async {
    extractor.error = const AudioExtractionException('no audio stream');
    expect(await failureOf(resolve()), JobFailureKind.unsupportedMedia);
  });

  test('a recognizer failure fails as transcriptionFailed', () async {
    recognizer.error = const SpeechRecognitionException('model missing');
    expect(await failureOf(resolve()), JobFailureKind.transcriptionFailed);
  });

  test('cancelling during extraction stops FFmpeg', () async {
    extractor.gate = Completer<void>();
    final run = resolve();
    await pumpEventQueue();
    token.cancel();
    expect(extractor.cancels, 1);
    extractor
      ..error = const CancelledException()
      ..gate!.complete();
    await expectLater(run, throwsA(isA<CancelledException>()));
  });

  test('cancelling during transcription stops the recognizer', () async {
    recognizer.gate = Completer<void>();
    final run = resolve();
    await pumpEventQueue();
    token.cancel();
    expect(recognizer.cancels, 1);
    expect(extractor.cancels, 0, reason: 'extraction had already finished');
    recognizer
      ..error = const CancelledException()
      ..gate!.complete();
    await expectLater(run, throwsA(isA<CancelledException>()));
    expect(File(extractor.produced!.path).existsSync(), isFalse);
  });

  group('outside the app', () {
    test('the lock-screen buttons pause and resume recognition', () async {
      recognizer.gate = Completer<void>();
      final run = resolve();
      await pumpEventQueue();
      background
        ..press(BackgroundJobCommand.pause)
        ..press(BackgroundJobCommand.resume);
      await pumpEventQueue();
      expect(recognizer.pauses, [true, false]);
      expect(background.calls, ['paused true', 'paused false'], reason: 'only the pause state');
      recognizer.gate!.complete();
      await run;
    });

    test('buttons pressed after recognition are ignored', () async {
      await resolve();
      background.press(BackgroundJobCommand.pause);
      await pumpEventQueue();
      expect(recognizer.pauses, isEmpty);
    });
  });
}
