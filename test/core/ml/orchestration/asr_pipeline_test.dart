import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/orchestration/asr_pipeline.dart';
import 'package:nutq/core/ml/orchestration/asr_pipeline_event.dart';
import 'package:nutq/core/ml/whisper/whisper_engine.dart';
import 'package:nutq/core/ml/whisper/whisper_engine_event.dart';
import 'package:nutq/core/network/error/api_error.dart';

/// Hand-written fake — mirrors the repo's convention of faking the
/// injected interface directly for cubit/pipeline tests rather than
/// reaching for mocktail.
class _FakeWhisperEngine implements WhisperEngine {
  _FakeWhisperEngine(this._eventsPerCall);

  /// One list of events per expected `transcribe()` call, consumed in order.
  final List<List<WhisperEngineEvent>> _eventsPerCall;
  String? loadedModelPath;
  bool cancelCalled = false;
  final List<String> transcribedPaths = [];

  @override
  Future<void> loadModel(String modelPath) async => loadedModelPath = modelPath;

  @override
  Stream<WhisperEngineEvent> transcribe(String audioPath, {required String language}) {
    transcribedPaths.add(audioPath);
    final events = _eventsPerCall.isNotEmpty ? _eventsPerCall.removeAt(0) : const <WhisperEngineEvent>[];
    return Stream.fromIterable(events);
  }

  @override
  Future<void> cancel() async => cancelCalled = true;

  @override
  Future<void> unloadModel() async {}
}

void main() {
  // See the comment in audio_chunker_test.dart — AsrPipeline drives the
  // real AudioChunker by default, which touches a platform EventChannel
  // even when it ends up falling back to "treat as one chunk".
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AsrPipeline', () {
    late AppDatabase db;
    late Directory tempDir;
    late ModelDownloadService modelDownloadService;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp('nutq_asr_pipeline_test');
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('emits modelNotDownloaded error when the model is missing and autoDownload is off', () async {
      modelDownloadService = ModelDownloadService(
        // Unused by this test — AsrPipeline only touches `getInstalled`,
        // never the network-download path, when the model row already
        // exists (or is deliberately absent with autoDownload off).
        dio: Dio(),
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );
      final engine = _FakeWhisperEngine([]);
      final pipeline = AsrPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        tempDirectory: () async => tempDir,
      );

      final events = await pipeline
          .transcribeFile(audioPath: '/tmp/clip.wav', language: 'ar', modelId: 'small')
          .toList();

      expect(events, hasLength(1));
      final error = (events.single as AsrPipelineError).error;
      expect(error, isA<ModelNotDownloadedError>());
      expect(engine.loadedModelPath, isNull);
    });

    test('transcribes a short (single-chunk) file end to end', () async {
      await db.modelsDao.upsert(
        InstalledModelsCompanion.insert(
          modelId: 'small',
          kind: 'whisper',
          tier: 'small',
          filePath: '/models/ggml-small.bin',
          downloadedAt: DateTime.utc(2026, 9, 1),
          sizeBytes: 1000,
          checksum: 'size:1000',
        ),
      );
      modelDownloadService = ModelDownloadService(
        // Unused by this test — AsrPipeline only touches `getInstalled`,
        // never the network-download path, when the model row already
        // exists (or is deliberately absent with autoDownload off).
        dio: Dio(),
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );

      final engine = _FakeWhisperEngine([
        [
          const WhisperEngineEvent.progress(percent: 50),
          const WhisperEngineEvent.segment(text: 'hello', start: Duration.zero, end: Duration(seconds: 1)),
          const WhisperEngineEvent.segment(
            text: 'world',
            start: Duration(seconds: 1),
            end: Duration(seconds: 2),
          ),
          const WhisperEngineEvent.progress(percent: 100),
          const WhisperEngineEvent.done(fullText: 'hello world'),
        ],
      ]);

      final pipeline = AsrPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        // ~5 minute chunking has no ffmpeg channel in the test VM, so
        // AudioChunker.chunk falls back to treating the file as one chunk
        // (see AudioChunker._probeDuration's documented fallback).
        tempDirectory: () async => tempDir,
      );

      final events = await pipeline
          .transcribeFile(audioPath: '/tmp/clip.wav', language: 'ar', modelId: 'small')
          .toList();

      expect(engine.loadedModelPath, '/models/ggml-small.bin');
      expect(engine.transcribedPaths, ['/tmp/clip.wav']);

      final progressEvents = events.whereType<AsrPipelineProgress>().toList();
      expect(progressEvents.map((e) => e.percent), [50, 100]);

      final done = events.whereType<AsrPipelineDone>().single;
      expect(done.fullText, 'hello world');
      expect(done.wordCount, 2);
    });

    test('batches transcript text by word count (batchWordCount)', () async {
      await db.modelsDao.upsert(
        InstalledModelsCompanion.insert(
          modelId: 'small',
          kind: 'whisper',
          tier: 'small',
          filePath: '/models/ggml-small.bin',
          downloadedAt: DateTime.utc(2026, 9, 1),
          sizeBytes: 1000,
          checksum: 'size:1000',
        ),
      );
      modelDownloadService = ModelDownloadService(
        // Unused by this test — AsrPipeline only touches `getInstalled`,
        // never the network-download path, when the model row already
        // exists (or is deliberately absent with autoDownload off).
        dio: Dio(),
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );

      final engine = _FakeWhisperEngine([
        [
          for (final word in ['one', 'two', 'three', 'four', 'five', 'six'])
            WhisperEngineEvent.segment(text: word, start: Duration.zero, end: Duration.zero),
          const WhisperEngineEvent.done(fullText: 'one two three four five six'),
        ],
      ]);

      final pipeline = AsrPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        batchWordCount: 5,
        tempDirectory: () async => tempDir,
      );

      final events = await pipeline
          .transcribeFile(audioPath: '/tmp/clip.wav', language: 'ar', modelId: 'small')
          .toList();

      final batches = events.whereType<AsrPipelineTranscriptBatch>().toList();
      // 6 one-word segments, batchWordCount 5: the 5th segment crosses the
      // threshold and flushes immediately ("one two three four five"); the
      // 6th starts a fresh batch, flushed by the pipeline's final
      // `flushBatch()` once the chunk loop ends ("six").
      expect(batches.map((b) => b.text), ['one two three four five', 'six']);
      expect(events.whereType<AsrPipelineDone>().single.wordCount, 6);
    });

    test('propagates engine errors as nativeEngineFailure', () async {
      await db.modelsDao.upsert(
        InstalledModelsCompanion.insert(
          modelId: 'small',
          kind: 'whisper',
          tier: 'small',
          filePath: '/models/ggml-small.bin',
          downloadedAt: DateTime.utc(2026, 9, 1),
          sizeBytes: 1000,
          checksum: 'size:1000',
        ),
      );
      modelDownloadService = ModelDownloadService(
        // Unused by this test — AsrPipeline only touches `getInstalled`,
        // never the network-download path, when the model row already
        // exists (or is deliberately absent with autoDownload off).
        dio: Dio(),
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );

      final engine = _FakeWhisperEngine([
        [const WhisperEngineEvent.error(message: 'native crash')],
      ]);

      final pipeline = AsrPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        tempDirectory: () async => tempDir,
      );

      final events = await pipeline
          .transcribeFile(audioPath: '/tmp/clip.wav', language: 'ar', modelId: 'small')
          .toList();

      final error = (events.single as AsrPipelineError).error;
      expect(error, isA<NativeEngineFailureError>());
      expect((error as NativeEngineFailureError).detail, 'native crash');
    });
  });
}
