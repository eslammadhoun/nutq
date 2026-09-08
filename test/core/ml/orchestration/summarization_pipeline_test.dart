import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/ml/llm/llm_engine.dart';
import 'package:nutq/core/ml/llm/llm_engine_event.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/orchestration/inference_lock.dart';
import 'package:nutq/core/ml/orchestration/summarization_pipeline.dart';
import 'package:nutq/core/ml/orchestration/summarization_pipeline_event.dart';
import 'package:nutq/core/network/error/api_error.dart';

/// `LlmEngine` mocked via mocktail, per this workstream's verification
/// requirement — contrasts with `AsrPipeline`'s hand-written
/// `_FakeWhisperEngine` fake (both are valid per the repo's "fake the
/// injected interface" convention; this file deliberately uses the
/// mocktail path for `LlmEngine`).
class MockLlmEngine extends Mock implements LlmEngine {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SummarizationPipeline', () {
    late AppDatabase db;
    late Directory tempDir;
    late ModelDownloadService modelDownloadService;
    late MockLlmEngine engine;

    setUpAll(() {
      registerFallbackValue(const <LlmEngineEvent>[]);
    });

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp('nutq_summarization_pipeline_test');
      engine = MockLlmEngine();
      modelDownloadService = ModelDownloadService(
        dio: Dio(),
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );
      when(() => engine.loadModel(any())).thenAnswer((_) async {});
      when(() => engine.cancel()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    Future<void> installModel({String modelId = '1b'}) => db.modelsDao.upsert(
      InstalledModelsCompanion.insert(
        modelId: modelId,
        kind: 'llm',
        tier: modelId,
        filePath: '/models/gemma-3-$modelId-it-q4_k_m.gguf',
        downloadedAt: DateTime.utc(2026, 9, 1),
        sizeBytes: 806058496,
        checksum: 'size:806058496',
      ),
    );

    test('emits modelNotDownloaded error when the model is missing and autoDownload is off', () async {
      final pipeline = SummarizationPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        inferenceLock: InferenceLock(),
      );

      final events = await pipeline
          .summarize(transcriptText: 'hello world', language: 'ar', modelId: '1b')
          .toList();

      expect(events, hasLength(1));
      final error = (events.single as SummarizationPipelineError).error;
      expect(error, isA<ModelNotDownloadedError>());
      verifyNever(() => engine.loadModel(any()));
    });

    test('summarizes end to end, parses valid JSON output, and loads the installed model', () async {
      await installModel();
      when(
        () => engine.generate(any(), maxTokens: any(named: 'maxTokens')),
      ).thenAnswer(
        (_) => Stream.fromIterable(const [
          LlmEngineEvent.token(text: '{"summary_text": "ملخص", '),
          LlmEngineEvent.token(text: '"tone_and_format": "formal", '),
          LlmEngineEvent.token(text: '"takeaways": [{"text": "نقطة"}]}'),
          LlmEngineEvent.done(fullText: ''),
        ]),
      );

      final pipeline = SummarizationPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        inferenceLock: InferenceLock(),
      );

      final events = await pipeline
          .summarize(transcriptText: 'some transcript', language: 'ar', modelId: '1b')
          .toList();

      verify(() => engine.loadModel('/models/gemma-3-1b-it-q4_k_m.gguf')).called(1);

      final done = events.whereType<SummarizationPipelineDone>().single;
      expect(done.summary.summaryText, 'ملخص');
      expect(done.summary.toneAndFormat, 'formal');
      expect(done.summary.takeaways, [
        {'text': 'نقطة'},
      ]);
      expect(done.summary.modelName, 'gemma-3-1b-it');
    });

    test('batches token text by word count (batchWordCount)', () async {
      await installModel();
      when(
        () => engine.generate(any(), maxTokens: any(named: 'maxTokens')),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          for (final word in ['one ', 'two ', 'three ', 'four ', 'five ', 'six'])
            LlmEngineEvent.token(text: word),
          const LlmEngineEvent.done(fullText: ''),
        ]),
      );

      final pipeline = SummarizationPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        inferenceLock: InferenceLock(),
        batchWordCount: 5,
      );

      final events = await pipeline
          .summarize(transcriptText: 'irrelevant', language: 'en', modelId: '1b')
          .toList();

      final batches = events.whereType<SummarizationPipelineTextBatch>().toList();
      // 6 one-word tokens, batchWordCount 5: the 5th token crosses the
      // threshold and flushes immediately; the 6th is flushed by the
      // pipeline's final flushBatch() once the stream ends.
      expect(batches.map((b) => b.text), ['one two three four five ', 'six']);
    });

    test('propagates engine errors as nativeEngineFailure', () async {
      await installModel();
      when(
        () => engine.generate(any(), maxTokens: any(named: 'maxTokens')),
      ).thenAnswer((_) => Stream.fromIterable(const [LlmEngineEvent.error(message: 'native crash')]));

      final pipeline = SummarizationPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        inferenceLock: InferenceLock(),
      );

      final events = await pipeline
          .summarize(transcriptText: 'irrelevant', language: 'en', modelId: '1b')
          .toList();

      final error = (events.single as SummarizationPipelineError).error;
      expect(error, isA<NativeEngineFailureError>());
      expect((error as NativeEngineFailureError).detail, 'native crash');
    });

    test('holds the shared InferenceLock for the duration of generate()', () async {
      await installModel();
      final lock = InferenceLock();

      when(() => engine.generate(any(), maxTokens: any(named: 'maxTokens'))).thenAnswer((_) async* {
        // Assert the lock is held while the engine is "generating".
        expect(lock.isLocked, isTrue);
        yield const LlmEngineEvent.token(text: '{"summary_text":"x","tone_and_format":"y","takeaways":[]}');
        yield const LlmEngineEvent.done(fullText: '');
      });

      final pipeline = SummarizationPipeline(
        engine: engine,
        modelDownloadService: modelDownloadService,
        inferenceLock: lock,
      );

      expect(lock.isLocked, isFalse);
      await pipeline.summarize(transcriptText: 'x', language: 'en', modelId: '1b').toList();
      expect(lock.isLocked, isFalse);
    });
  });
}
