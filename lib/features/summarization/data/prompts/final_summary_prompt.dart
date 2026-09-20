import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

class FinalSummaryPrompt {
  const FinalSummaryPrompt._();

  static String build({
    required List<String> summaries,
    required List<String> keyFacts,
    required List<String> entities,
    required List<String> numbers,
    required SummaryLength length,
    ContentLanguage language = ContentLanguage.ar,
  }) =>
      '''You are an ${language.promptName} summarization assistant. Write the final summary of a full lecture or recording from the partial summaries below.

Rules:
- Start directly with the subject; do not start with ${language == ContentLanguage.ar ? '"يتحدث النص عن"' : '"The text talks about"'}.
- Explain the main topic, then cover the major themes in order.
- Preserve important conclusions, numbers, dates, names and technical terms exactly as written.
- Remove unnecessary examples and repetition.
- Use only information supported by the material below; do not invent or speculate.
- Do not mention that you are an AI.
- Write natural, coherent ${language.promptName}.
- ${_lengthInstruction(length, language)}

PARTIAL SUMMARIES:
${_numbered(summaries)}

KEY FACTS:
${_bullets(keyFacts)}

IMPORTANT NAMES AND TERMS:
${_bullets(entities)}

IMPORTANT NUMBERS AND DATES:
${_bullets(numbers)}

FINAL SUMMARY:''';

  static String _lengthInstruction(
    SummaryLength length,
    ContentLanguage language,
  ) => switch (length) {
    SummaryLength.short =>
      'Length: 5 to 8 short bullet points (about ${length.minWords}-${length.maxWords} ${language.promptName} words in total).',
    SummaryLength.medium =>
      'Length: about ${length.minWords}-${length.maxWords} ${language.promptName} words in connected paragraphs.',
    SummaryLength.detailed =>
      'Length: about ${length.minWords}-${length.maxWords} ${language.promptName} words in connected paragraphs; cover every major theme.',
  };

  static String _numbered(List<String> items) => [
    for (var i = 0; i < items.length; i++) '${i + 1}. ${items[i]}',
  ].join('\n');

  static String _bullets(List<String> items) =>
      items.isEmpty ? '- (none)' : items.map((i) => '- $i').join('\n');
}
