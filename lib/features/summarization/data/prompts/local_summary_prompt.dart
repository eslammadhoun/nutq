class LocalSummaryPrompt {
  const LocalSummaryPrompt._();

  static String build(String chunkText) =>
      '''You are an Arabic summarization assistant.

Summarize the provided transcript segment.

Rules:
1. Preserve the main idea.
2. Preserve important facts.
3. Preserve numbers, dates, names, and technical terms.
4. Remove repetition and low-value details.
5. Do not add information that is not supported by the transcript.
6. Do not speculate.
7. Use clear natural Arabic.
8. Do not mention that you are an AI.
9. Do not start with "يتحدث النص عن".
10. Prefer concise connected prose.

SOURCE:
$chunkText''';
}
