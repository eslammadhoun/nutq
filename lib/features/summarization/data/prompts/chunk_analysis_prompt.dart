class ChunkAnalysisPrompt {
  const ChunkAnalysisPrompt._();

  static String build(String chunkText) =>
      '''You are an Arabic information extraction assistant.

Analyze the provided transcript segment.

Rules:
- Use only information explicitly supported by the text.
- Do not invent facts.
- Preserve names, numbers, dates, technical terms, and important relationships.
- Identify the central idea.
- Identify important supporting points.
- Identify important facts.
- Ignore filler and repetition.
- Write in Arabic.

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
