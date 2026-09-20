import 'package:nutq/core/domain/content_language.dart';

class ChunkAnalysisPrompt {
  const ChunkAnalysisPrompt._();

  static String build(String chunkText, {ContentLanguage language = ContentLanguage.ar}) =>
      '''You are an ${language.promptName} information extraction assistant.

Analyze the provided transcript segment.

Rules:
- Use only information explicitly supported by the text.
- Do not invent facts.
- Preserve names, numbers, dates, technical terms, and important relationships.
- Identify the central idea.
- Identify important supporting points.
- Identify important facts.
- Ignore filler and repetition.
- Write in ${language.promptName}.

Return exactly:

MAIN:
...

POINTS:
- ...
- ...
- ...

FACTS:
- ...
- ...
- ...

IMPORTANT_TERMS:
- ...
- ...

SOURCE:
$chunkText''';
}
