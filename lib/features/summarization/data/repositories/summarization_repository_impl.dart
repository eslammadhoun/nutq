import 'package:nutq/features/summarization/data/cache/summarization_cache.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_token_counter.dart';
import 'package:nutq/features/summarization/data/parsing/chunk_analysis_parser.dart';
import 'package:nutq/features/summarization/data/prompts/chunk_analysis_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/final_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/local_summary_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/merge_prompt.dart';
import 'package:nutq/features/summarization/data/prompts/prompt_version.dart';
import 'package:nutq/features/summarization/domain/entities/chunk_analysis.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Builds prompts, runs them through [GemmaLocalDataSource], parses replies,
/// tracks usage, and (optionally) caches outputs.
class SummarizationRepositoryImpl implements SummarizationRepository {
  SummarizationRepositoryImpl({
    required GemmaLocalDataSource dataSource,
    TokenCounter? tokenCounter,
    this.baseConfig = const GemmaGenerationConfig(),
    this.cache,
    this.modelVersion = summarizationModelId,
    this.parser = const ChunkAnalysisParser(),
  }) : _dataSource = dataSource,
       tokenCounter = tokenCounter ?? CachingTokenCounter(GemmaTokenCounter(dataSource));

  final GemmaLocalDataSource _dataSource;
  final GemmaGenerationConfig baseConfig;
  final SummarizationCache? cache;
  final String modelVersion;
  final ChunkAnalysisParser parser;

  @override
  final TokenCounter tokenCounter;

  GenerationStats _stats = const GenerationStats();

  /// Reserved headroom so prompt + reply never touch the context limit.
  static const _contextMargin = 128;
  static const _analysisOutputTokens = 400;
  static const _localSummaryOutputTokens = 320;
  static const _mergeOutputTokens = 480;
  static const _maxFinalOutputTokens = 1600;
  static const _tokensPerArabicWord = 2.2;

  @override
  String get modelId => modelVersion;

  @override
  String get promptVersion => summarizationPromptVersion;

  @override
  GenerationStats get stats => _stats;

  @override
  void resetStats() => _stats = const GenerationStats();

  @override
  Future<void> prepare() => _dataSource.activate();

  @override
  Future<void> cancel() => _dataSource.cancel();

  @override
  Future<ChunkAnalysis> analyzeChunk(
    TranscriptChunk chunk, {
    ContentLanguage language = ContentLanguage.ar,
  }) async {
    final response = await _generate(
      stage: 'analysis',
      prompt: ChunkAnalysisPrompt.build(chunk.text, language: language),
      config: baseConfig.copyWith(maxOutputTokens: _analysisOutputTokens),
    );
    return parser.parse(chunk.id, response);
  }

  @override
  Future<String> summarizeChunk(
    TranscriptChunk chunk, {
    ContentLanguage language = ContentLanguage.ar,
  }) => _generate(
    stage: 'local',
    prompt: LocalSummaryPrompt.build(chunk.text, language: language),
    config: baseConfig.copyWith(maxOutputTokens: _localSummaryOutputTokens),
  );

  @override
  Future<String> mergeSummaries(MergeRequest request) async {
    final config = baseConfig.copyWith(maxOutputTokens: _mergeOutputTokens);
    final summaries = [for (final s in request.summaries) s.text];
    final facts = List.of(request.facts);
    final evidence = List.of(request.evidence);

    String build() => MergePrompt.build(
      summaries: summaries,
      facts: facts,
      evidence: evidence,
      language: request.language,
    );

    // Shed evidence first, then facts, until the prompt fits the window.
    var prompt = build();
    while (await _overBudget(prompt, config) && (evidence.isNotEmpty || facts.isNotEmpty)) {
      if (evidence.isNotEmpty) {
        evidence.removeLast();
      } else {
        facts.removeLast();
      }
      prompt = build();
    }
    return _generate(stage: 'merge', prompt: prompt, config: config);
  }

  @override
  Future<String> generateFinalSummary(
    FinalSummaryRequest request, {
    void Function(String partialText)? onPartial,
  }) async {
    final outputTokens = (request.length.maxWords * _tokensPerArabicWord)
        .round()
        .clamp(_analysisOutputTokens, _maxFinalOutputTokens);
    final config = baseConfig.copyWith(maxOutputTokens: outputTokens);
    final summaries = [for (final s in request.summaries) s.text];
    final facts = List.of(request.keyFacts);
    final entities = List.of(request.entities);
    final numbers = List.of(request.numbers);

    String build() => FinalSummaryPrompt.build(
      summaries: summaries,
      keyFacts: facts,
      entities: entities,
      numbers: numbers,
      length: request.length,
      language: request.language,
    );

    var prompt = build();
    while (await _overBudget(prompt, config) && (facts.isNotEmpty || entities.isNotEmpty || numbers.isNotEmpty)) {
      if (facts.isNotEmpty) {
        facts.removeLast();
      } else if (entities.isNotEmpty) {
        entities.removeLast();
      } else {
        numbers.removeLast();
      }
      prompt = build();
    }
    return _generate(
      stage: 'final-${request.length.name}',
      prompt: prompt,
      config: config,
      onPartial: onPartial,
    );
  }

  Future<bool> _overBudget(String prompt, GemmaGenerationConfig config) async {
    final promptTokens = await tokenCounter.count(prompt);
    return promptTokens + config.maxOutputTokens + _contextMargin > config.contextTokens;
  }

  Future<String> _generate({
    required String stage,
    required String prompt,
    required GemmaGenerationConfig config,
    void Function(String partialText)? onPartial,
  }) async {
    final store = cache;
    final key = store == null
        ? null
        : SummarizationCache.keyFor(
            modelVersion: modelVersion,
            promptVersion: summarizationPromptVersion,
            stage: stage,
            input: prompt,
            configSignature: config.cacheSignature,
          );
    if (store != null && key != null) {
      final hit = await store.read(key);
      if (hit != null) {
        onPartial?.call(hit);
        return hit;
      }
    }

    final response = await _dataSource.generate(prompt, config, onPartial: onPartial);
    _stats += GenerationStats(
      inputTokens: response.inputTokens,
      outputTokens: response.outputTokens,
      generationTimeMs: response.durationMs,
      calls: 1,
    );
    if (store != null && key != null) await store.write(key, response.text);
    return response.text;
  }
}
