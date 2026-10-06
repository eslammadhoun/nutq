import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';

/// Scripted stand-in for the on-device model. Responds by prompt type so the
/// whole pipeline runs without a real model.
class FakeGemma implements GemmaLocalDataSource {
  FakeGemma({this.responder});

  /// Override to script per-prompt behaviour; return null to use defaults.
  Future<String?> Function(String prompt, int call)? responder;

  final List<String> prompts = [];
  bool activated = false;
  bool cancelled = false;
  bool failEverything = false;

  /// Pause between streamed words (only when streaming is requested).
  Duration wordDelay = Duration.zero;

  int get calls => prompts.length;

  @override
  Future<bool> isModelAvailable() async => true;

  @override
  Future<void> activate() async {
    activated = true;
    cancelled = false;
  }

  @override
  Future<int> countTokens(String text) async => text.trim().split(RegExp(r'\s+')).length;

  @override
  Future<void> cancel() async => cancelled = true;

  /// Times the token-counting session was closed.
  int tokenizerCloses = 0;

  @override
  Future<void> closeTokenizer() async => tokenizerCloses++;

  /// Times the model was freed, and whether it is loaded now.
  int disposals = 0;

  @override
  Future<void> dispose() async {
    disposals++;
    activated = false;
  }

  @override
  Future<GemmaResponse> generate(
    String prompt,
    GemmaGenerationConfig config, {
    void Function(String partialText)? onPartial,
  }) async {
    if (cancelled) throw const CancelledException();
    prompts.add(prompt);
    if (failEverything) throw const GemmaGenerationException('boom');
    final scripted = await responder?.call(prompt, prompts.length);
    // A stop requested while the call was in flight, as the real model does.
    if (cancelled) throw const CancelledException();
    final text = scripted ?? defaultResponse(prompt);
    if (onPartial != null) {
      // Stream word by word, yielding between words so events interleave.
      final words = text.split(' ');
      for (var i = 1; i <= words.length; i++) {
        if (cancelled) throw const CancelledException();
        onPartial(words.take(i).join(' '));
        await Future<void>.delayed(wordDelay);
      }
    }
    return GemmaResponse(
      text: text,
      inputTokens: prompt.length ~/ 4,
      outputTokens: text.length ~/ 4,
      durationMs: 10,
    );
  }

  /// A distinct sentence per call, so later sections are not dropped as
  /// restatements of earlier ones.
  static String defaultResponse(String prompt) =>
      'ملخص القسم ${prompt.hashCode.toUnsigned(16)} عن موضوع مهم.';
}
