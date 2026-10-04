import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/summarization/domain/entities/summary_length.dart';

part 'summary.freezed.dart';

/// A finished summary and how it was produced.
@freezed
sealed class Summary with _$Summary {
  const factory Summary({
    required String summaryText,
    required SummaryLength length,
    required List<String> takeaways,
    required String modelName,
    required String promptVersion,

    /// True when the heuristic checks could not match some detail of the
    /// summary to the transcript.
    @Default(false) bool needsReview,
    int? tokensIn,
    int? tokensOut,
    int? processingTimeMs,
  }) = _Summary;
}
