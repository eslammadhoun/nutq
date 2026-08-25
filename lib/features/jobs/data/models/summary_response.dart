import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary_response.freezed.dart';
part 'summary_response.g.dart';

@freezed
sealed class SummaryResponse with _$SummaryResponse {
  const factory SummaryResponse({
    @JsonKey(name: 'summary_text') required String summaryText,
    @JsonKey(name: 'tone_and_format') required String toneAndFormat,
    required List<Map<String, dynamic>> takeaways,
    @JsonKey(name: 'model_name') required String modelName,
    @JsonKey(name: 'prompt_version') required String promptVersion,
    @JsonKey(name: 'tokens_in') int? tokensIn,
    @JsonKey(name: 'tokens_out') int? tokensOut,
  }) = _SummaryResponse;

  factory SummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SummaryResponseFromJson(json);
}
