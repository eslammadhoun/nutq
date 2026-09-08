import 'dart:convert';

import 'package:nutq/features/jobs/domain/entities/summary.dart';

/// Tolerant parser for `LlmEngine`'s raw generated text into a [Summary].
///
/// Never hard-fails a job over malformed structured output (plan Section
/// 5): valid JSON is parsed normally; JSON wrapped in a ```json fenced
/// block is unwrapped first; anything else falls back to treating the
/// entire raw output as [Summary.summaryText] with empty takeaways and an
/// empty tone/format label, so a summarization job still completes with
/// *something* useful even if the model didn't follow the prompt's JSON
/// instruction exactly.
class SummaryResponseParser {
  const SummaryResponseParser();

  Summary parse(
    String rawOutput, {
    required String modelName,
    required String promptVersion,
    int? tokensIn,
    int? tokensOut,
  }) {
    final decoded = _tryDecode(rawOutput);
    if (decoded != null) {
      final takeawaysRaw = decoded['takeaways'];
      final takeaways = <Map<String, dynamic>>[
        if (takeawaysRaw is List)
          for (final entry in takeawaysRaw)
            if (entry is Map)
              {'text': (entry['text'] ?? entry.values.firstOrNull ?? '').toString()}
            else if (entry is String)
              {'text': entry},
      ];

      return Summary(
        summaryText: (decoded['summary_text'] ?? '').toString(),
        toneAndFormat: (decoded['tone_and_format'] ?? '').toString(),
        takeaways: takeaways,
        modelName: modelName,
        promptVersion: promptVersion,
        tokensIn: tokensIn,
        tokensOut: tokensOut,
      );
    }

    // Fallback: not parseable structured output — never hard-fail the job.
    return Summary(
      summaryText: rawOutput.trim(),
      toneAndFormat: '',
      takeaways: const [],
      modelName: modelName,
      promptVersion: promptVersion,
      tokensIn: tokensIn,
      tokensOut: tokensOut,
    );
  }

  Map<String, dynamic>? _tryDecode(String rawOutput) {
    for (final candidate in _candidates(rawOutput)) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // Try the next candidate.
      }
    }
    return null;
  }

  /// Progressively looser attempts at isolating a JSON object from
  /// [rawOutput]: the trimmed text as-is, the contents of a fenced
  /// ```json ... ``` (or bare ``` ... ```) block if present, and finally
  /// the substring between the first `{` and the last `}` (handles stray
  /// prose the model tacked on before/after the JSON).
  Iterable<String> _candidates(String rawOutput) sync* {
    final trimmed = rawOutput.trim();
    yield trimmed;

    final fenceMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)```',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (fenceMatch != null) {
      yield fenceMatch.group(1)!.trim();
    }

    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      yield trimmed.substring(firstBrace, lastBrace + 1);
    }
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
