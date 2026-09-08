/// Shared static metadata shape for a downloadable on-device model tier —
/// implemented by [WhisperModelSpec] (ASR) and `LlmModelSpec` (Gemma
/// summarization). Lets [ModelDownloadService] (see
/// `model_download_service.dart`) drive download/verify/DB-record for both
/// kinds through one code path instead of duplicating that machinery per
/// model kind, per the plan's Section 5 instruction to extend, not
/// duplicate, the whisper-era download service.
abstract class ModelSpec {
  /// Stable id, also used as the `modelId`/`tier` in the `installed_models`
  /// table and as part of the on-disk filename.
  String get id;

  String get displayName;

  int get approxSizeBytes;

  Uri get downloadUrl;

  bool get isDefault;

  /// `installed_models.kind` discriminator — `'whisper'` or `'llm'` today.
  String get kind;

  /// On-disk filename the downloaded file is stored under.
  String get fileName;
}
