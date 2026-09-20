import 'package:flutter/foundation.dart';

/// Sampling and budget parameters for one Gemma generation. Defaults follow
/// the plan (§14) and stay configurable — no magic numbers elsewhere.
@immutable
class GemmaGenerationConfig {
  const GemmaGenerationConfig({
    this.temperature = 0.20,
    this.topK = 20,
    this.topP = 0.90,
    this.seed = 47,
    this.maxOutputTokens = 512,
    this.contextTokens = 4096,
    this.useGpu = false,
  });

  final double temperature;
  final int topK;
  final double topP;
  final int seed;

  /// Cap on *generated* tokens.
  final int maxOutputTokens;

  /// Model context window (prompt + reply share it). The bundled
  /// `gemma3-1b-it-q4` build is exported with a 4096-token KV cache.
  final int contextTokens;

  /// CPU is the default: slower but the most predictable output for a 1B
  /// model. Quality > speed.
  final bool useGpu;

  GemmaGenerationConfig copyWith({
    double? temperature,
    int? topK,
    double? topP,
    int? seed,
    int? maxOutputTokens,
    int? contextTokens,
    bool? useGpu,
  }) => GemmaGenerationConfig(
    temperature: temperature ?? this.temperature,
    topK: topK ?? this.topK,
    topP: topP ?? this.topP,
    seed: seed ?? this.seed,
    maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
    contextTokens: contextTokens ?? this.contextTokens,
    useGpu: useGpu ?? this.useGpu,
  );

  /// Stable string for cache keys.
  String get cacheSignature => '$temperature|$topK|$topP|$seed|$maxOutputTokens|$contextTokens';
}
