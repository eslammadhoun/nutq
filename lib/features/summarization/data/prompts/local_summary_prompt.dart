import 'package:nutq/features/summarization/domain/entities/summary_language.dart';

class LocalSummaryPrompt {
  const LocalSummaryPrompt._();

  static String build(String chunkText, {SummaryLanguage language = SummaryLanguage.ar}) =>
      '''You are an ${language.promptName} summarization assistant.

Summarize the provided transcript segment.

Rules:
1. Preserve the main idea.
2. Preserve important facts.
3. Preserve numbers, dates, names, and technical terms.
4. Remove repetition and low-value details.
5. Do not add information that is not supported by the transcript.
6. Do not speculate.
7. Use clear natural ${language.promptName}.
8. Do not mention that you are an AI.
9. ${_openingRule(language)}
10. Prefer concise connected prose.

SOURCE:
$chunkText''';

  static String _openingRule(SummaryLanguage language) => switch (language) {
    SummaryLanguage.ar => 'Do not start with "يتحدث النص عن".',
    SummaryLanguage.en => 'Do not start with "The text talks about".',
  };
}
