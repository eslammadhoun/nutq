import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/datasources/summarizer_model.dart';
import 'package:nutq/features/summarization/data/prompts/summary_prompt.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/text/output_format.dart';
import 'package:nutq/features/summarization/domain/text/repetition.dart';

/// Builds section prompts, runs them through [GemmaLocalDataSource], cleans
/// the replies and tracks usage.
class SummarizationRepositoryImpl implements SummarizationRepository {
  SummarizationRepositoryImpl({
    required this._dataSource,
    this.model = activeSummarizerModel,
    this.baseConfig = const GemmaGenerationConfig(),
  });

  final GemmaLocalDataSource _dataSource;
  final SummarizerModel model;
  final GemmaGenerationConfig baseConfig;

  GenerationStats _stats = const GenerationStats();

  /// Fraction of the context under which the cheap character estimate is
  /// trusted instead of a tokenizer round trip.
  static const _estimateSafetyMargin = 0.85;

  @override
  String get modelId => model.id;

  @override
  String get promptVersion => summarizationPromptVersion;

  @override
  int get contextTokens => model.contextTokens;

  /// A small context reserves less, since what is reserved for output is
  /// taken from the source text.
  @override
  int get maxOutputTokens => contextTokens >= 2048 ? 384 : 256;

  @override
  GenerationStats get stats => _stats;

  @override
  void resetStats() => _stats = const GenerationStats();

  @override
  Future<void> prepare() => _dataSource.activate();

  @override
  Future<void> cancel() => _dataSource.cancel();

  @override
  Future<void> release() => _dataSource.dispose();

  @override
  Future<int> countTokens(String text) => _dataSource.countTokens(text);

  @override
  Future<void> doneCounting() => _dataSource.closeTokenizer();

  String _prompt(String text, ContentLanguage language, {int? sentences}) => sectionSummaryPrompt(
    text,
    language: language,
    useTrainingPrompt: model.useTrainingPrompt,
    sentences: sentences,
  );

  @override
  Future<int> promptOverheadTokens(ContentLanguage language) => countTokens(_prompt('', language));

  @override
  Future<bool> fits(String text, ContentLanguage language) async {
    final prompt = _prompt(text, language, sentences: 6);
    // Worst case 3 chars/token, so this never under-estimates.
    final estimate = (prompt.length / 3).ceil();
    if (estimate + maxOutputTokens <= contextTokens * _estimateSafetyMargin) return true;
    return await countTokens(prompt) + maxOutputTokens <= contextTokens;
  }

  @override
  Future<String> summarizeSection(
    SectionRequest request, {
    void Function(String partialText)? onPartial,
  }) async {
    final GemmaResponse response;
    try {
      response = await _dataSource.generate(
        _prompt(request.text, request.language, sentences: request.sentences),
        baseConfig.copyWith(maxOutputTokens: request.maxOutputTokens),
        onPartial: onPartial,
      );
    } on GemmaGenerationException {
      // Nothing usable even after the data source's retry: the pipeline
      // retries the section with its key points, or leaves it out.
      return '';
    }
    _stats += GenerationStats(
      inputTokens: response.inputTokens,
      outputTokens: response.outputTokens,
      generationTimeMs: response.durationMs,
      prefillTimeMs: response.prefillMs,
      calls: 1,
      loopStops: response.stoppedOnLoop ? 1 : 0,
      capped: response.hitCap ? 1 : 0,
    );
    return cleanSummary(response.text, language: request.language);
  }

  /// Removes what is not summary: an echoed prompt, chat preambles, paragraphs
  /// in the wrong language, loops and markdown.
  static String cleanSummary(String text, {required ContentLanguage language}) {
    var result = stripPromptLeakage(text.trim());
    result = stripChatPreamble(result);
    if (language == ContentLanguage.ar) result = dropOffLanguageParagraphs(result);
    if (hasSevereRepetition(result)) result = removeRepetitionTail(result);
    return plainSummaryText(result).trim();
  }
}
