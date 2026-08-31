import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_file.freezed.dart';

/// A local media file selected by the user and staged for upload.
@freezed
sealed class UploadFile with _$UploadFile {
  const factory UploadFile({
    required String name,
    required String path,
    required int sizeBytes,
    required String contentType,
  }) = _UploadFile;

  static const int maxBytes = 524288000;
}
