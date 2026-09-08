import 'package:nutq/core/ml/llm/llm_engine_event.dart';

/// Abstraction over an on-device llama.cpp (GGUF) text-generation engine.
///
/// Kept free of `dart:ffi` types and of any `lib/features/jobs/` import so
/// it stays mockable with `mocktail` and reusable outside the jobs feature
/// — mirrors [WhisperEngine]'s shape (see
/// `lib/core/ml/whisper/whisper_engine.dart`) one for one:
/// `loadModel`/a generation stream/`cancel`/`unloadModel`.
///
/// ## Cancellation guarantee
///
/// The wrapped package ([LlmEngineImpl]'s `llama_cpp_dart`) runs generation
/// inside its own worker isolate and exposes cancellation as a Dart
/// mechanism: cancelling the subscription on [generate]'s stream sends a
/// `CancelCommand` to that worker, which the decode loop observes and stops
/// on **between individual token-generation steps** — i.e. cancellation is
/// cooperative at token granularity, not truly preemptive mid-token, but
/// materially finer-grained than [WhisperEngine]'s chunk-boundary-only
/// guarantee (a single llama.cpp decode step is milliseconds, not minutes).
/// [cancel] here additionally sets an internal flag so a *not-yet-started*
/// `generate()` call returns immediately with
/// [LlmEngineEvent.error] instead of starting a doomed generation.
abstract class LlmEngine {
  /// Loads the GGUF model at [modelPath] into native memory. Must be
  /// called before [generate]. Safe to call again with a different path to
  /// swap models (unloads the previous one first).
  Future<void> loadModel(String modelPath);

  /// Generates a completion for [prompt] (expected to already be formatted
  /// per the model's chat template — see `SummarizationPromptBuilder`),
  /// capped at [maxTokens] tokens if given. Emits [LlmEngineEvent.token]
  /// chunks while running and a terminal [LlmEngineEvent.done] or
  /// [LlmEngineEvent.error]. The stream closes after the terminal event.
  Stream<LlmEngineEvent> generate(String prompt, {int? maxTokens});

  /// Requests cancellation of an in-flight [generate] call. See the class
  /// doc comment for the exact guarantee this provides.
  Future<void> cancel();

  /// Releases the loaded model from native memory.
  Future<void> unloadModel();
}
