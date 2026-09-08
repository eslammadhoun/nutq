import 'dart:async';

import 'package:nutq/core/ml/llm/llm_engine.dart';
import 'package:nutq/core/ml/llm/llm_engine_event.dart';
import 'package:nutq/core/ml/llm/summarization_prompt_builder.dart';
import 'package:nutq/core/ml/llm/summary_response_parser.dart';
import 'package:nutq/core/ml/models/llm_model_spec.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/orchestration/inference_lock.dart';
import 'package:nutq/core/ml/orchestration/summarization_pipeline_event.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';

/// Standalone, summarization-only pipeline stub: transcript text in,
/// structured `Summary` out — mirrors `AsrPipeline`'s shape and scope one
/// for one. Does **not** touch the `Jobs`/`Summaries` DB tables or
/// `JobsCubit`/`JobDetailCubit` wiring; combining this with `AsrPipeline`
/// into a real end-to-end job (`JobOrchestrator`/`LocalJobProcessor`) is a
/// later workstream's job, same as `AsrPipeline`.
///
/// ## Intended runtime flow
/// 1. [summarize] checks [ModelDownloadService] for the requested Gemma
///    tier. Missing + [autoDownloadModel] false → [SummarizationPipelineEvent.error]
///    with `ApiError.modelNotDownloaded`. Missing + true → downloads it
///    first (progress not surfaced on this stream — same convention as
///    `AsrPipeline.transcribeFile`).
/// 2. [engine].loadModel() loads the GGUF file. `LlmEngineImpl` spawns
///    (or reuses) `llama_cpp_dart`'s own worker isolate here — there is no
///    separate isolate-management step this pipeline needs to do itself
///    (see `LlmEngineImpl`'s doc comment for why, contrasted with
///    `AsrPipeline`'s `WhisperIsolateEngine`).
/// 3. [SummarizationPromptBuilder] renders a single Gemma-chat-template
///    prompt asking for strict JSON matching `Summary`'s shape, in the
///    transcript's own language.
/// 4. [inferenceLock] is held for the whole generate() call — whisper.cpp
///    must not run while llama.cpp is decoding (plan Section 5;
///    `InferenceLock`'s doc comment).
/// 5. `LlmEngine.generate()`'s token stream is coalesced into
///    [SummarizationPipelineEvent.textBatch] every [batchWindow] or
///    [batchWordCount] words, whichever comes first — same cadence
///    constants as `AsrPipeline`.
/// 6. On the engine's terminal `done`, [SummaryResponseParser] parses the
///    accumulated raw text into a `Summary` (tolerantly — see that
///    class's doc comment) and [SummarizationPipelineEvent.done] is
///    emitted. On failure/cancellation: [SummarizationPipelineEvent.error].
///
/// **Not verified end-to-end on-device in this workstream** — there is no
/// simulator/device available in this environment. The above is the
/// intended flow for a follow-up manual verification pass, same caveat as
/// `AsrPipeline`.
class SummarizationPipeline {
  SummarizationPipeline({
    required this._engine,
    required this._modelDownloadService,
    this.promptBuilder = const SummarizationPromptBuilder(),
    this.responseParser = const SummaryResponseParser(),
    this.batchWindow = const Duration(milliseconds: 150),
    this.batchWordCount = 5,
    this.maxTokens = 1024,
    InferenceLock? inferenceLock,
  }) : _inferenceLock = inferenceLock ?? InferenceLock.shared;

  final LlmEngine _engine;
  final ModelDownloadService _modelDownloadService;
  final SummarizationPromptBuilder promptBuilder;
  final SummaryResponseParser responseParser;
  final InferenceLock _inferenceLock;

  /// Batch coalescing window — whichever of this or [batchWordCount] is
  /// reached first flushes a [SummarizationPipelineEvent.textBatch].
  /// Matches `AsrPipeline`'s constants.
  final Duration batchWindow;
  final int batchWordCount;

  /// Cap passed to `LlmEngine.generate`.
  final int maxTokens;

  bool _cancelRequested = false;

  Stream<SummarizationPipelineEvent> summarize({
    required String transcriptText,
    required String language,
    String modelId = '1b',
    bool autoDownloadModel = false,
  }) {
    final controller = StreamController<SummarizationPipelineEvent>();
    unawaited(
      _run(
        controller,
        transcriptText: transcriptText,
        language: language,
        modelId: modelId,
        autoDownloadModel: autoDownloadModel,
      ),
    );
    return controller.stream;
  }

  Future<void> cancel() async {
    _cancelRequested = true;
    await _engine.cancel();
  }

  Future<void> _run(
    StreamController<SummarizationPipelineEvent> controller, {
    required String transcriptText,
    required String language,
    required String modelId,
    required bool autoDownloadModel,
  }) async {
    _cancelRequested = false;

    try {
      var installed = await _modelDownloadService.getInstalled(modelId);
      if (installed == null) {
        if (!autoDownloadModel) {
          controller.add(SummarizationPipelineEvent.error(error: ApiError.modelNotDownloaded(modelId)));
          await controller.close();
          return;
        }
        final spec = LlmModelSpec.byId(modelId);
        if (spec == null) {
          controller.add(SummarizationPipelineEvent.error(error: ApiError.modelNotDownloaded(modelId)));
          await controller.close();
          return;
        }
        final downloadResult = await _modelDownloadService.download(spec);
        switch (downloadResult) {
          case Failure(:final error):
            controller.add(SummarizationPipelineEvent.error(error: error));
            await controller.close();
            return;
          case Success(:final data):
            installed = data;
        }
      }

      if (_cancelRequested) {
        controller.add(const SummarizationPipelineEvent.error(error: ApiError.processingCancelled()));
        await controller.close();
        return;
      }

      await _engine.loadModel(installed.filePath);

      final prompt = promptBuilder.build(transcriptText: transcriptText, language: language);

      final textBuffer = StringBuffer();
      final batch = StringBuffer();
      var batchWordsSeen = 0;
      Timer? batchTimer;

      void flushBatch() {
        batchTimer?.cancel();
        batchTimer = null;
        if (batch.isEmpty) return;
        controller.add(SummarizationPipelineEvent.textBatch(text: batch.toString()));
        batch.clear();
        batchWordsSeen = 0;
      }

      void addToBatch(String text) {
        if (text.isEmpty) return;
        batch.write(text);
        batchWordsSeen += text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        if (batchWordsSeen >= batchWordCount) {
          flushBatch();
        } else {
          batchTimer ??= Timer(batchWindow, flushBatch);
        }
      }

      if (_cancelRequested) {
        controller.add(const SummarizationPipelineEvent.error(error: ApiError.processingCancelled()));
        await controller.close();
        return;
      }

      await _inferenceLock.acquire();
      try {
        await for (final event in _engine.generate(prompt, maxTokens: maxTokens)) {
          switch (event) {
            case LlmEngineToken(:final text):
              textBuffer.write(text);
              addToBatch(text);
            case LlmEngineDone():
              break;
            case LlmEngineError(:final message):
              controller.add(SummarizationPipelineEvent.error(error: ApiError.nativeEngineFailure(message)));
              await controller.close();
              return;
          }
        }
      } finally {
        _inferenceLock.release();
      }

      flushBatch();

      final summary = responseParser.parse(
        textBuffer.toString(),
        modelName: 'gemma-3-$modelId-it',
        promptVersion: promptBuilder.promptVersion,
      );
      controller.add(SummarizationPipelineEvent.done(summary: summary));
      await controller.close();
    } catch (e) {
      controller.add(SummarizationPipelineEvent.error(error: ApiError.nativeEngineFailure(e.toString())));
      await controller.close();
    }
  }
}
