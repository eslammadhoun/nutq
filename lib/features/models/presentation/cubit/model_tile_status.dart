/// Install status of one whisper model tier, as rendered by the Models
/// screen's list.
enum ModelTileStatus { notInstalled, downloading, installed }

class ModelTileState {
  const ModelTileState({
    required this.id,
    required this.displayName,
    required this.approxSizeBytes,
    required this.isDefault,
    this.status = ModelTileStatus.notInstalled,
    this.downloadProgress = 0,
  });

  final String id;
  final String displayName;
  final int approxSizeBytes;
  final bool isDefault;
  final ModelTileStatus status;

  /// 0.0–1.0, meaningful only while [status] is [ModelTileStatus.downloading].
  final double downloadProgress;

  ModelTileState copyWith({ModelTileStatus? status, double? downloadProgress}) => ModelTileState(
    id: id,
    displayName: displayName,
    approxSizeBytes: approxSizeBytes,
    isDefault: isDefault,
    status: status ?? this.status,
    downloadProgress: downloadProgress ?? this.downloadProgress,
  );
}
