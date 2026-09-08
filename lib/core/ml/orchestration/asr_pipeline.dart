import 'dart:async';
import 'dart:io';

import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/whisper_model_spec.dart';
import 'package:nutq/core/ml/orchestration/asr_pipeline_event.dart';
import 'package:nutq/core/ml/whisper/audio_chunker.dart';
import 'package:nutq/core/ml/whisper/whisper_engine.dart';
import 'package:nutq/core/ml/whisper/whisper_engine_event.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// Standalone, ASR-only pipeline stub: audio file in, transcript text out,
/// proving the whisper pipeline end-to-end without any of the
/// `Jobs`/`Transcripts` DB writes or `JobsCubit`/`JobDetailCubit` wiring —
/// that integration is explicitly a later workstream's job
/// (`JobOrchestrator`/`LocalJobProcessor`).
///
/// ## Intended runtime flow
/// 1. [transcribeFile] checks [ModelDownloadService] for the requested
///    model tier. Missing + [autoDownloadModel] false →
///    [AsrPipelineEvent.error] with `ApiError.modelNotDownloaded`. Missing +
///    true → downloads it first (progress not surfaced on this stream; a
///    caller wanting download progress should call
///    [ModelDownloadService.download] itself beforehand).
/// 2. [engine].loadModel() loads the model file into the (isolate-backed,
///    in production) engine.
/// 3. [chunker] splits the source audio into ~5-minute windows (a no-op —
///    returns the original path — for anything shorter).
/// 4. Each chunk is transcribed via [engine].transcribe(); segment text is
///    accumulated and de-duplicated at chunk boundaries
///    ([AudioChunker.dedupeChunkBoundary]); progress/segment events are
///    coalesced into [AsrPipelineEvent.transcriptBatch]/`.progress` (see
///    [batchWindow]/[batchWordCount]) before being relayed out.
/// 5. On completion: [AsrPipelineEvent.done] with the joined transcript,
///    word count, and audio duration. On failure/cancellation:
///    [AsrPipelineEvent.error].
///
/// **Not verified end-to-end on-device in this workstream** — there is no
/// simulator/device available in this environment. The above is the
/// intended flow for a follow-up manual verification pass.
class AsrPipeline {
  AsrPipeline({
    required this._engine,
    required this._modelDownloadService,
    this.chunker = const AudioChunker(),
    this.batchWindow = const Duration(milliseconds: 150),
    this.batchWordCount = 5,
    Future<Directory> Function()? tempDirectory,
  }) : _tempDirectory = tempDirectory ?? path_provider.getTemporaryDirectory;

  final WhisperEngine _engine;
  final ModelDownloadService _modelDownloadService;
  final AudioChunker chunker;

  /// Batch coalescing window — whichever of this or [batchWordCount] is
  /// reached first flushes a [AsrPipelineEvent.transcriptBatch].
  final Duration batchWindow;
  final int batchWordCount;

  final Future<Directory> Function() _tempDirectory;

  bool _cancelRequested = false;

  Stream<AsrPipelineEvent> transcribeFile({
    required String audioPath,
    required String language,
    String modelId = 'small',
    bool autoDownloadModel = false,
  }) {
    final controller = StreamController<AsrPipelineEvent>();
    unawaited(_run(controller, audioPath: audioPath, language: language, modelId: modelId, autoDownloadModel: autoDownloadModel));
    return controller.stream;
  }

  Future<void> cancel() async {
    _cancelRequested = true;
    await _engine.cancel();
  }

  Future<void> _run(
    StreamController<AsrPipelineEvent> controller, {
    required String audioPath,
    required String language,
    required String modelId,
    required bool autoDownloadModel,
  }) async {
    _cancelRequested = false;
    final startedAt = DateTime.now();

    try {
      var installed = await _modelDownloadService.getInstalled(modelId);
      if (installed == null) {
        if (!autoDownloadModel) {
          controller.add(AsrPipelineEvent.error(error: ApiError.modelNotDownloaded(modelId)));
          await controller.close();
          return;
        }
        final spec = WhisperModelSpec.byId(modelId);
        if (spec == null) {
          controller.add(AsrPipelineEvent.error(error: ApiError.modelNotDownloaded(modelId)));
          await controller.close();
          return;
        }
        final downloadResult = await _modelDownloadService.download(spec);
        switch (downloadResult) {
          case Failure(:final error):
            controller.add(AsrPipelineEvent.error(error: error));
            await controller.close();
            return;
          case Success(:final data):
            installed = data;
        }
      }

      await _engine.loadModel(installed.filePath);

      final chunkDir = Directory('${(await _tempDirectory()).path}/asr_chunks_${DateTime.now().microsecondsSinceEpoch}');
      final chunkPaths = await chunker.chunk(audioPath, outputDir: chunkDir);

      final textBuffer = StringBuffer();
      var previousChunkText = '';
      final batch = StringBuffer();
      var batchWordsSeen = 0;
      Timer? batchTimer;

      void flushBatch() {
        batchTimer?.cancel();
        batchTimer = null;
        if (batch.isEmpty) return;
        controller.add(AsrPipelineEvent.transcriptBatch(text: batch.toString()));
        batch.clear();
        batchWordsSeen = 0;
      }

      void addToBatch(String text) {
        if (text.isEmpty) return;
        batch.write(text.endsWith(' ') || batch.isEmpty ? text : ' $text');
        batchWordsSeen += text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        if (batchWordsSeen >= batchWordCount) {
          flushBatch();
        } else {
          batchTimer ??= Timer(batchWindow, flushBatch);
        }
      }

      for (var i = 0; i < chunkPaths.length; i++) {
        if (_cancelRequested) {
          controller.add(const AsrPipelineEvent.error(error: ApiError.processingCancelled()));
          await controller.close();
          return;
        }

        final chunkText = StringBuffer();
        await for (final event in _engine.transcribe(chunkPaths[i], language: language)) {
          switch (event) {
            case WhisperEngineProgress(:final percent):
              controller.add(AsrPipelineEvent.progress(chunkIndex: i, chunkTotal: chunkPaths.length, percent: percent));
            case WhisperEngineSegment(:final text):
              chunkText.write(chunkText.isEmpty ? text : ' $text');
              // Streamed live as each segment is enumerated — note this
              // preview is not itself boundary-deduped (only the final
              // `done` transcript is, via `dedupedText` below); whisper
              // segments arrive in one burst per chunk (see
              // WhisperEngineImpl's doc comment), not truly incrementally,
              // but the `await for` still yields control between
              // iterations so the batch window/word-count coalescing below
              // has real segments to coalesce rather than one giant flush.
              addToBatch(text);
            case WhisperEngineDone():
              break;
            case WhisperEngineError(:final message):
              controller.add(AsrPipelineEvent.error(error: ApiError.nativeEngineFailure(message)));
              await controller.close();
              return;
          }
        }

        var dedupedText = chunkText.toString();
        if (i > 0) {
          dedupedText = AudioChunker.dedupeChunkBoundary(previousChunkText, dedupedText);
        }
        if (dedupedText.isNotEmpty) {
          textBuffer.write(textBuffer.isEmpty ? dedupedText : ' $dedupedText');
        }
        previousChunkText = chunkText.toString();
      }

      flushBatch();

      final fullText = textBuffer.toString().trim();
      final wordCount = fullText.isEmpty
          ? 0
          : fullText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      controller.add(
        AsrPipelineEvent.done(fullText: fullText, wordCount: wordCount, duration: DateTime.now().difference(startedAt)),
      );
      await controller.close();
    } catch (e) {
      controller.add(AsrPipelineEvent.error(error: ApiError.nativeEngineFailure(e.toString())));
      await controller.close();
    }
  }
}
