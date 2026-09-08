import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_engine_event.freezed.dart';

/// Event vocabulary emitted by [LlmEngine.generate] — mirrors
/// `WhisperEngineEvent`'s shape (progress/content events + one terminal
/// event) for the LLM side of on-device inference.
@freezed
sealed class LlmEngineEvent with _$LlmEngineEvent {
  /// A chunk of newly-generated text (one or more sampled tokens' decoded
  /// text, as delivered by the wrapped package — see [LlmEngineImpl]'s doc
  /// comment for exactly how token-level output is coalesced into this).
  const factory LlmEngineEvent.token({required String text}) = LlmEngineToken;

  /// Terminal — generation finished (end-of-generation, max tokens reached,
  /// or cancellation acknowledged).
  const factory LlmEngineEvent.done({required String fullText}) = LlmEngineDone;

  /// Terminal — the native engine failed unexpectedly.
  const factory LlmEngineEvent.error({required String message}) = LlmEngineError;
}
