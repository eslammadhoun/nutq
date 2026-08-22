import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_slot_response.freezed.dart';
part 'upload_slot_response.g.dart';

@freezed
sealed class UploadSlotResponse with _$UploadSlotResponse {
  const factory UploadSlotResponse({
    @JsonKey(name: 'upload_url') required String uploadUrl,
    @JsonKey(name: 'upload_token') required String uploadToken,
    @JsonKey(name: 'expires_in_seconds') required int expiresInSeconds,
  }) = _UploadSlotResponse;

  factory UploadSlotResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadSlotResponseFromJson(json);
}
