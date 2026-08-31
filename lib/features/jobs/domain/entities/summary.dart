import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary.freezed.dart';

/// Domain equivalent of [SummaryResponse].
@freezed
sealed class Summary with _$Summary {
  const factory Summary({
    required String summaryText,
    required String toneAndFormat,
    required List<Map<String, dynamic>> takeaways,
    required String modelName,
    required String promptVersion,
    int? tokensIn,
    int? tokensOut,
  }) = _Summary;
}
