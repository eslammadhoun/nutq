import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';

/// Token counts of one finished generation.
class LlmUsage {
  const LlmUsage({this.inputTokens = 0, this.outputTokens = 0});

  final int inputTokens;
  final int outputTokens;
}

/// One conversation with the model: a prompt in, a reply out.
abstract interface class LlmSession {
  Future<void> setPrompt(String prompt);

  /// The whole reply.
  Future<String> respond();

  /// The reply as it is generated, one token (or a few) at a time.
  Stream<String> respondStream();

  /// Model-tokenizer token count.
  Future<int> countTokens(String text);

  /// Usage of the last reply; meaningful after it finishes.
  LlmUsage get usage;

  /// Stops generating now.
  Future<void> stop();

  Future<void> close();
}

/// The thin boundary to the on-device inference engine. Everything the data
/// source does with it (retries, cancellation, streaming, response cleanup,
/// lifecycle) is testable against a fake; only the adapter for the real engine
/// (`FlutterGemmaRuntime`) needs a device.
abstract interface class LlmRuntime {
  bool get isLoaded;

  /// Whether the model is installed and usable, without loading it.
  Future<bool> isModelAvailable();

  /// Prepares the engine and loads the model. Throws if it cannot.
  Future<void> load();

  /// A fresh, independent conversation configured by [config].
  Future<LlmSession> openSession(GemmaGenerationConfig config);

  /// A long-lived session used only for counting tokens.
  Future<LlmSession> openTokenizer();

  /// Frees the model's memory.
  Future<void> unload();
}
