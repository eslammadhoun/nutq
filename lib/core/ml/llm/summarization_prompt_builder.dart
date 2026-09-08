/// Builds the single prompt `SummarizationPipeline` sends to `LlmEngine`,
/// formatted per Gemma's chat template (`&lt;start_of_turn&gt;user ...
/// &lt;end_of_turn&gt;` then `&lt;start_of_turn&gt;model`, per
/// `llama_cpp_dart`'s `KnownChatTemplates.gemma` and Gemma 3's model card)
/// and requesting
/// strict JSON matching `Summary` (`lib/features/jobs/domain/entities/
/// summary.dart`): `summaryText`, `toneAndFormat`, `takeaways` (a list of
/// `{"text": "..."}` objects — the same shape `job_mappers.dart` produces
/// from the backend's `Takeaways` rows), plus `modelName`/`promptVersion`
/// bookkeeping the pipeline fills in itself (not requested from the model).
///
/// Gemma has no dedicated system role — its own chat template folds a
/// system message into the next user turn — so this builder emits a single
/// user turn with the instructions inline rather than a separate system
/// turn the template would just merge anyway.
class SummarizationPromptBuilder {
  const SummarizationPromptBuilder({this.promptVersion = 'v1'});

  /// Bumped whenever the instructions below change in a way that could
  /// alter model output — stored alongside the produced `Summary` so a
  /// later prompt revision doesn't silently look like a different model.
  final String promptVersion;

  /// [transcriptText] is the ASR output to summarize; [language] is the
  /// transcript's ISO 639-1 language (e.g. `'ar'`) — the model is asked to
  /// reply in that language.
  String build({required String transcriptText, required String language}) {
    final instructions =
        '''
You are summarizing a speech transcript. Respond with a single, strictly
valid JSON object and nothing else — no markdown, no commentary, no code
fence. The JSON object must have exactly these keys:
- "summary_text": a concise summary of the transcript, written in the same
  language as the transcript (language code "$language").
- "tone_and_format": a short label describing the tone and format of the
  source content (e.g. "formal meeting", "casual conversation", "lecture").
- "takeaways": a JSON array of the most important points, each an object
  of the form {"text": "..."}, written in the same language as the
  transcript.

Transcript:
"""
$transcriptText
"""

Respond with only the JSON object described above.''';

    return '<start_of_turn>user\n$instructions<end_of_turn>\n<start_of_turn>model\n';
  }
}
