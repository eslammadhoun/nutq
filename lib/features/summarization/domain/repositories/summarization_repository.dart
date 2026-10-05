import 'package:nutq/core/domain/content_language.dart';

/// One section of the source to summarize.
class SectionRequest {
  const SectionRequest({
    required this.text,
    required this.language,
    required this.sentences,
    required this.maxOutputTokens,
  });

  final String text;

  /// Language the summary is written in.
  final ContentLanguage language;

  /// Sentences to ask for (ignored by a model prompted as it was fine-tuned).
  final int sentences;
  final int maxOutputTokens;
}

/// Cumulative model usage for one summarization job.
class GenerationStats {
  const GenerationStats({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.generationTimeMs = 0,
    this.prefillTimeMs = 0,
    this.calls = 0,
    this.loopStops = 0,
    this.capped = 0,
  });

  final int inputTokens;
  final int outputTokens;
  final int generationTimeMs;
  final int prefillTimeMs;
  final int calls;

  /// Calls stopped early because the model started repeating itself.
  final int loopStops;

  /// Calls that ran into their output cap.
  final int capped;

  GenerationStats operator +(GenerationStats other) => GenerationStats(
    inputTokens: inputTokens + other.inputTokens,
    outputTokens: outputTokens + other.outputTokens,
    generationTimeMs: generationTimeMs + other.generationTimeMs,
    prefillTimeMs: prefillTimeMs + other.prefillTimeMs,
    calls: calls + other.calls,
    loopStops: loopStops + other.loopStops,
    capped: capped + other.capped,
  );
}

/// Everything the pipeline needs from the model, without exposing prompts,
/// the Gemma runtime, or response cleanup to the domain layer.
abstract class SummarizationRepository {
  /// Identifies the model that produces summaries (stored with each result).
  String get modelId;

  /// Identifies the prompt templates in use.
  String get promptVersion;

  /// Prompt + output tokens one call can hold.
  int get contextTokens;

  /// Upper bound on one call's output. Each section gets a smaller cap from
  /// its share of the summary; this only stops a call that lost its way.
  int get maxOutputTokens;

  /// Ensures the model is installed and loaded. Throws
  /// `SummarizationFailure(modelUnavailable)` when it cannot be.
  Future<void> prepare();

  /// Model-tokenizer token count.
  Future<int> countTokens(String text);

  /// Frees what token counting holds. Called once the sections are planned,
  /// before any is written, so generation has the memory to itself.
  Future<void> doneCounting();

  /// Tokens the section prompt takes around its text.
  Future<int> promptOverheadTokens(ContentLanguage language);

  /// Whether a section prompt for [text] fits the context with room for
  /// [maxOutputTokens].
  Future<bool> fits(String text, ContentLanguage language);

  /// Summarizes one section and returns the cleaned summary, which is empty
  /// when nothing usable was left (an echoed prompt, the wrong language, a
  /// loop). [onPartial] receives the text generated so far.
  Future<String> summarizeSection(
    SectionRequest request, {
    void Function(String partialText)? onPartial,
  });

  /// Usage accumulated since the last [resetStats].
  GenerationStats get stats;

  void resetStats();

  /// Stops any in-flight generation. Safe to call when idle.
  Future<void> cancel();

  /// Unloads the model to free memory. The next job reloads it on demand.
  Future<void> release();
}
