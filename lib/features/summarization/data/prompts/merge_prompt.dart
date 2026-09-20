import 'package:nutq/core/domain/content_language.dart';

class MergePrompt {
  const MergePrompt._();

  static String build({
    required List<String> summaries,
    required List<String> facts,
    required List<String> evidence,
    ContentLanguage language = ContentLanguage.ar,
  }) =>
      '''You are merging summaries of an ${language.promptName} lecture.

Rules:
- Preserve information supported by the source.
- Do not invent new facts.
- Resolve repetition.
- Preserve important relationships.
- Preserve important numbers, names and technical terms.
- Do not add conclusions that are not supported.
- Produce a coherent ${language.promptName} synthesis.

LOCAL SUMMARIES:
${_numbered(summaries)}

IMPORTANT FACTS:
${_bullets(facts)}

SOURCE EVIDENCE:
${_bullets(evidence)}

OUTPUT:''';

  static String _numbered(List<String> items) => [
    for (var i = 0; i < items.length; i++) '${i + 1}. ${items[i]}',
  ].join('\n');

  static String _bullets(List<String> items) =>
      items.isEmpty ? '- (none)' : items.map((i) => '- $i').join('\n');
}
