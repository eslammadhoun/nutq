import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/text/coverage.dart';
import 'package:nutq/features/summarization/domain/text/key_line_extractor.dart';
import 'package:nutq/features/summarization/domain/text/output_format.dart';
import 'package:nutq/features/summarization/domain/text/transcript_cleaner.dart';

/// An event on the stream returned by [SummarizeTranscript.stream].
sealed class SummarizationUpdate {
  const SummarizationUpdate();
}

class SummarizationProgressUpdate extends SummarizationUpdate {
  const SummarizationProgressUpdate(this.progress);

  final SummarizationProgress progress;
}

/// The summary as generated so far (accumulated text, word by word).
class SummarizationPartialSummaryUpdate extends SummarizationUpdate {
  const SummarizationPartialSummaryUpdate(this.text);

  final String text;
}

class SummarizationCompletedUpdate extends SummarizationUpdate {
  const SummarizationCompletedUpdate(this.result);

  final SummaryResult result;
}

/// Splits the source into units and scores them. Top-level so it can run in
/// an isolate.
CoverageTracker analyzeSource(({String text, double keyPointFactor}) request) => CoverageTracker(
  const KeyLineExtractor().analyze(request.text),
  importanceFactor: request.keyPointFactor,
);

/// Writes the summary section by section, in source order:
///
/// 1. Moonshine's line seams are removed ([cleanTranscriptSeams]) and the
///    source is split into units. Filler (greetings, hand-overs) is dropped
///    ([CoverageTracker.substantive]); the rest is split into consecutive
///    sections sized so the summary comes out near
///    [SummarizationConfig.summaryRatio] of the source. Each section gets one
///    call, so the summary follows the source from beginning to end.
/// 2. A section that writes too little — nothing left after cleanup (wrong
///    language, chat filler, a loop) or a sentence or so — is retried once
///    with just its key points, a different input that usually gets a real
///    answer.
/// 3. Paragraphs are joined in source order, without the "يتحدث الكاتب عن…"
///    opener each one tends to start with, and with sentences that restate an
///    earlier paragraph dropped.
///
/// There is no merge step: a 1B model merging summaries loses detail and
/// repeats itself, and every merge costs another full prefill.
class SummarizeTranscript {
  const SummarizeTranscript({
    required this.repository,
    this.background = const InlineBackgroundWork(),
  });

  final SummarizationRepository repository;

  /// Where the pure, CPU-heavy source analysis runs (257 ms for a 100-minute
  /// lecture). The app passes an isolate-backed one so it never blocks the UI.
  final BackgroundWork background;

  /// Throws [SummarizationFailure] or [CancelledException].
  Future<SummaryResult> call(
    String transcript,
    SummarizationConfig config, {
    CancellationToken? cancellation,
    void Function(SummarizationProgress progress)? onProgress,
    void Function(String partialSummary)? onPartialSummary,
  }) async {
    final token = cancellation ?? CancellationToken();
    final watch = Stopwatch()..start();
    void report(SummarizationStage stage, [int? done, int? total]) =>
        onProgress?.call(SummarizationProgress(stage, processedChunks: done, totalChunks: total));

    report(SummarizationStage.preparing);
    final text = cleanTranscriptSeams(transcript.trim());
    if (text.isEmpty) {
      throw const SummarizationFailure(SummarizationFailureKind.emptyTranscript);
    }
    final sourceWords = _wordCount(text);
    if (sourceWords < config.minWordsToSummarize) {
      report(SummarizationStage.completed);
      return SummaryResult(
        summary: text,
        debug: SummaryDebugInfo(sectionCount: 0, processingTimeMs: watch.elapsedMilliseconds),
      );
    }

    token.throwIfCancelled();
    await repository.prepare();
    token.throwIfCancelled();
    repository.resetStats();

    final tracker = await background.run(analyzeSource, (
      text: text,
      keyPointFactor: config.keyPointFactor,
    ));
    final ratio = config.summaryRatio(sourceWords);
    final tokensPerWord = await _measureTokensPerWord(text);
    // A text that repeats itself throughout has no distinctive terms, so every
    // unit scores as filler; then summarize all of it rather than nothing.
    final units = tracker.substantive.isNotEmpty ? tracker.substantive : tracker.units;
    final sections = await _packUnits(
      units,
      config,
      tokensPerWord: tokensPerWord,
      maxWords: config.sectionWords(ratio),
    );
    token.throwIfCancelled();

    // Paragraphs so far, each anchored at the first source unit it covers.
    final paragraphs = <({int anchor, String text})>[];
    String assembled() {
      final ordered = [...paragraphs]..sort((a, b) => a.anchor.compareTo(b.anchor));
      return ordered.map((p) => stripReportingPhrases(p.text)).join('\n\n');
    }

    // Summarizes [batch], adds the result at its place in the order and
    // returns the words it added.
    Future<int> write(List<SourceUnit> batch) async {
      final before = assembled();
      final prefix = before.isEmpty ? '' : '$before\n\n';
      final words = batch.fold<int>(0, (sum, u) => sum + u.wordCount);
      final summary = await repository.summarizeSection(
        SectionRequest(
          text: _joinUnits(batch),
          language: config.language,
          sentences: (words * ratio / 16).round().clamp(3, 6),
          maxOutputTokens: _outputCap(words * tokensPerWord, ratio),
        ),
        onPartial: onPartialSummary == null ? null : (p) => onPartialSummary('$prefix$p'),
      );
      token.throwIfCancelled();
      final fresh = dropRestatedSentences(summary, before, ignore: tracker.topicTerms);
      if (fresh.isNotEmpty) paragraphs.add((anchor: batch.first.index, text: fresh));
      onPartialSummary?.call(assembled());
      return _wordCount(fresh);
    }

    final keyPoints = tracker.important.map((u) => u.index).toSet();
    var retries = 0;
    var dropped = 0;

    for (var i = 0; i < sections.length; i++) {
      report(SummarizationStage.summarizing, i, sections.length);
      final section = sections[i];
      var added = await write(section);

      final expected = section.fold<int>(0, (sum, u) => sum + u.wordCount) * ratio;
      final keys = [
        for (final u in section)
          if (keyPoints.contains(u.index)) u,
      ];
      if (added < expected / 3 && keys.isNotEmpty && keys.length < section.length) {
        retries++;
        added += await write(keys);
      }
      if (added == 0) dropped++;
    }

    final summary = assembled();
    if (summary.isEmpty) {
      throw const SummarizationFailure(
        SummarizationFailureKind.generationFailed,
        'no section produced a summary',
      );
    }
    report(SummarizationStage.completed, sections.length, sections.length);

    final stats = repository.stats;
    final debug = SummaryDebugInfo(
      sectionCount: sections.length,
      retries: retries,
      droppedSections: dropped,
      processingTimeMs: watch.elapsedMilliseconds,
      inputTokens: stats.inputTokens,
      outputTokens: stats.outputTokens,
      generationTimeMs: stats.generationTimeMs,
      prefillTimeMs: stats.prefillTimeMs,
      summaryRatio: ratio,
      coverage: tracker.ratio(summary),
    );
    if (config.debugLogging) {
      debugPrint(_logLine(debug, stats, sourceWords, _wordCount(summary), tracker));
    }
    return SummaryResult(summary: summary, needsReview: dropped > 0, debug: debug);
  }

  /// Runs the pipeline and streams progress as it happens, ending with one
  /// [SummarizationCompletedUpdate]. Failures arrive as stream errors
  /// ([SummarizationFailure] / [CancelledException]). Cancelling
  /// the subscription cancels the job.
  Stream<SummarizationUpdate> stream(
    String transcript,
    SummarizationConfig config, {
    CancellationToken? cancellation,
  }) {
    final token = cancellation ?? CancellationToken();
    late final StreamController<SummarizationUpdate> controller;
    controller = StreamController<SummarizationUpdate>(
      onListen: () async {
        try {
          final result = await call(
            transcript,
            config,
            cancellation: token,
            onProgress: (p) {
              if (!controller.isClosed) controller.add(SummarizationProgressUpdate(p));
            },
            onPartialSummary: (text) {
              if (!controller.isClosed) controller.add(SummarizationPartialSummaryUpdate(text));
            },
          );
          if (!controller.isClosed) controller.add(SummarizationCompletedUpdate(result));
        } catch (e, st) {
          if (!controller.isClosed) controller.addError(e, st);
        } finally {
          if (!controller.isClosed) await controller.close();
        }
      },
      onCancel: token.cancel,
    );
    return controller.stream;
  }

  /// Output cap for one call reading [inputTokens] of source: well above what
  /// the call should write, so it stops a runaway call without cutting a
  /// normal one.
  int _outputCap(num inputTokens, double ratio) =>
      math.max(160, (inputTokens * ratio * 2).ceil()).clamp(0, repository.maxOutputTokens);

  /// Tokens per word of [text], measured once on a sample, so sections can be
  /// sized without a tokenizer call per candidate.
  Future<double> _measureTokensPerWord(String text) async {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(300).toList();
    if (words.isEmpty) return 2;
    return await repository.countTokens(words.join(' ')) / words.length;
  }

  /// Groups [units] (source order) into sections of at most [maxWords] whose
  /// prompt fits one call.
  Future<List<List<SourceUnit>>> _packUnits(
    List<SourceUnit> units,
    SummarizationConfig config, {
    required double tokensPerWord,
    required int maxWords,
  }) async {
    final overhead = await repository.promptOverheadTokens(config.language);
    final available = repository.contextTokens - repository.maxOutputTokens - overhead;
    final limit = math.max(40, math.min(maxWords, (available / tokensPerWord * 0.9).floor()));

    final batches = <List<SourceUnit>>[];
    var current = <SourceUnit>[];
    var words = 0;
    for (final unit in units) {
      if (current.isNotEmpty && words + unit.wordCount > limit) {
        batches.add(current);
        current = [];
        words = 0;
      }
      current.add(unit);
      words += unit.wordCount;
    }
    if (current.isNotEmpty) batches.add(current);

    // The estimate can be off for unusual text; split what does not fit.
    final verified = <List<SourceUnit>>[];
    Future<void> verify(List<SourceUnit> batch) async {
      if (batch.length == 1 || await repository.fits(_joinUnits(batch), config.language)) {
        verified.add(batch);
        return;
      }
      final mid = batch.length ~/ 2;
      await verify(batch.sublist(0, mid));
      await verify(batch.sublist(mid));
    }

    for (final batch in batches) {
      await verify(batch);
    }
    return verified;
  }

  /// Joins units into prompt text: neighbours run on as one passage, a gap in
  /// the source starts a new paragraph.
  static String _joinUnits(List<SourceUnit> units) {
    final buffer = StringBuffer();
    for (var i = 0; i < units.length; i++) {
      if (i > 0) buffer.write(units[i].index == units[i - 1].index + 1 ? ' ' : '\n\n');
      buffer.write(units[i].text);
    }
    return buffer.toString();
  }

  static int _wordCount(String text) =>
      text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  /// Same shape as gemma_playground's `[summarizer]` line, so device runs can
  /// be compared across the two apps. Counts and timings only.
  String _logLine(
    SummaryDebugInfo d,
    GenerationStats stats,
    int sourceWords,
    int summaryWords,
    CoverageTracker tracker,
  ) {
    String s(int ms) => '${(ms / 1000).toStringAsFixed(2)}s';
    return '[summarizer] model=${repository.modelId} words=$sourceWords '
        'coverage=${d.coverage?.toStringAsFixed(2)} key=${tracker.important.length} '
        'read=${tracker.substantive.length}/${tracker.units.length} '
        'retries=${d.retries} dropped=${d.droppedSections} '
        'ratio=${d.summaryRatio.toStringAsFixed(3)} calls=${stats.calls} '
        'prefill=${s(d.prefillTimeMs)} decode=${s(d.decodeTimeMs)} '
        'total=${s(d.processingTimeMs)} in=${d.inputTokens}tok out=${d.outputTokens}tok '
        'prefill_tps=${d.prefillTokensPerSecond.toStringAsFixed(1)} '
        'decode_tps=${d.decodeTokensPerSecond.toStringAsFixed(1)} '
        'summary=${summaryWords}w loop_stops=${stats.loopStops} capped=${stats.capped}';
  }
}
