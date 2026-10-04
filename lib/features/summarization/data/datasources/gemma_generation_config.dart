import 'package:flutter/foundation.dart';

/// Sampling and budget parameters for one Gemma generation. Conservative
/// decoding: summarization benefits from consistency more than creativity.
@immutable
class GemmaGenerationConfig {
  const GemmaGenerationConfig({
    this.temperature = 0.20,
    this.topK = 20,
    this.topP = 0.90,
    this.seed = 47,
    this.maxOutputTokens = 384,
  });

  final double temperature;
  final int topK;
  final double topP;
  final int seed;

  /// Cap on *generated* tokens. The context window is the model's
  /// (`SummarizerModel.contextTokens`); prompt and reply share it.
  final int maxOutputTokens;

  GemmaGenerationConfig copyWith({int? maxOutputTokens}) => GemmaGenerationConfig(
    temperature: temperature,
    topK: topK,
    topP: topP,
    seed: seed,
    maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
  );
}
