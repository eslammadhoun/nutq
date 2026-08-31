import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_slot.freezed.dart';

/// Domain equivalent of [UploadSlotResponse] — a presigned slot to upload
/// a locally-picked file to.
@freezed
sealed class UploadSlot with _$UploadSlot {
  const factory UploadSlot({
    required String uploadUrl,
    required String uploadToken,
    required int expiresInSeconds,
  }) = _UploadSlot;
}
