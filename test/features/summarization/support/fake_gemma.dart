import 'package:nutq/features/summarization/data/datasources/gemma_generation_config.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';

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

  @override
  Future<void> dispose() async {}

  @override
  Future<GemmaResponse> generate(String prompt, GemmaGenerationConfig config) async {
    if (cancelled) throw const SummarizationCancelledException();
    prompts.add(prompt);
    if (failEverything) throw const GemmaGenerationException('boom');
    final scripted = await responder?.call(prompt, prompts.length);
    final text = scripted ?? defaultResponse(prompt);
    return GemmaResponse(text: text, inputTokens: prompt.length ~/ 4, outputTokens: text.length ~/ 4, durationMs: 10);
  }

  static String defaultResponse(String prompt) {
    if (prompt.contains('information extraction assistant')) {
      return 'MAIN:\nفكرة رئيسية عن الموضوع\n\nPOINTS:\n- نقطة أولى\n- نقطة ثانية\n\n'
          'FACTS:\n- حقيقة مهمة\n\nIMPORTANT_TERMS:\n- مصطلح';
    }
    if (prompt.contains('merging summaries')) return 'ملخص مدمج للأقسام';
    if (prompt.contains('final summary of a full lecture')) return 'الملخص النهائي للمحاضرة';
    return 'ملخص القسم';
  }
}
