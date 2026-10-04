import 'dart:async';

import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';

/// A scripted conversation.
class FakeLlmSession implements LlmSession {
  FakeLlmSession({
    this.reply = 'رد النموذج',
    this.tokens,
    this.error,
    this.gate,
    this.usage = const LlmUsage(inputTokens: 100, outputTokens: 40),
    this.tokenCount = 7,
    this.closeError,
  });

  /// The reply for `respond()`; also what `respondStream()` yields when
  /// [tokens] is not given (word by word).
  final String reply;

  /// What `respondStream()` yields, token by token.
  final List<String>? tokens;

  /// Thrown instead of replying.
  final Object? error;

  /// The reply waits here until completed.
  final Completer<void>? gate;

  @override
  final LlmUsage usage;

  final int tokenCount;
  final Object? closeError;

  String? prompt;
  bool stopped = false;
  bool closed = false;
  int stopCalls = 0;

  @override
  Future<void> setPrompt(String prompt) async => this.prompt = prompt;

  @override
  Future<String> respond() async {
    if (gate != null) await gate!.future;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (error != null) throw error!;
    return reply;
  }

  @override
  Stream<String> respondStream() async* {
    if (gate != null && error != null) await gate!.future;
    if (error != null) {
      yield* Stream<String>.error(error!);
      return;
    }
    final parts = tokens ?? reply.split(' ').map((w) => '$w ').toList();
    for (final part in parts) {
      if (gate != null) await gate!.future;
      if (stopped) return;
      yield part;
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Future<int> countTokens(String text) async => tokenCount;

  @override
  Future<void> stop() async {
    stopCalls++;
    stopped = true;
  }

  @override
  Future<void> close() async {
    closed = true;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (closeError != null) throw closeError!;
  }
}

/// A runtime whose sessions come from [sessionFor] (one per `openSession`).
class FakeLlmRuntime implements LlmRuntime {
  FakeLlmRuntime({this.sessionFor, this.loadError, this.loadDelay});

  FakeLlmSession Function(int attempt)? sessionFor;
  Object? loadError;
  Completer<void>? loadDelay;

  bool loaded = false;
  int loadCalls = 0;
  int unloadCalls = 0;
  bool available = true;

  final sessions = <FakeLlmSession>[];
  final configs = <GemmaGenerationConfig>[];
  FakeLlmSession? tokenizer;
  int tokenizerOpens = 0;
  Object? unloadError;

  @override
  bool get isLoaded => loaded;

  @override
  Future<bool> isModelAvailable() async => available;

  @override
  Future<void> load() async {
    loadCalls++;
    if (loadDelay != null) await loadDelay!.future;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (loadError != null) throw loadError!;
    loaded = true;
  }

  @override
  Future<LlmSession> openSession(GemmaGenerationConfig config) async {
    configs.add(config);
    final session = sessionFor?.call(sessions.length) ?? FakeLlmSession();
    sessions.add(session);
    return session;
  }

  @override
  Future<LlmSession> openTokenizer() async {
    tokenizerOpens++;
    return tokenizer = FakeLlmSession();
  }

  @override
  Future<void> unload() async {
    unloadCalls++;
    loaded = false;
    // A test double that throws whatever the test scripted.
    // ignore: only_throw_errors
    if (unloadError != null) throw unloadError!;
  }
}
