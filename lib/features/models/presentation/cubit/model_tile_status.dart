/// Install status of one model tier, as rendered by the Models screen's
/// list.
enum ModelTileStatus { notInstalled, downloading, installed }

class ModelTileState {
  const ModelTileState({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.approxSizeBytes,
    required this.isDefault,
    this.status = ModelTileStatus.notInstalled,
    this.downloadProgress = 0,
    this.minRamBytes = 0,
    this.ramBlocked = false,
    this.ramUnknown = false,
  });

  final String id;

  /// `'whisper'` or `'llm'` — matches `installed_models.kind` /
  /// `ModelSpec.kind`, used to group tiles on the Models screen.
  final String kind;
  final String displayName;
  final int approxSizeBytes;
  final bool isDefault;
  final ModelTileStatus status;

  /// 0.0–1.0, meaningful only while [status] is [ModelTileStatus.downloading].
  final double downloadProgress;

  /// RAM floor this tier is gated behind (0 = no gate). Only meaningful
  /// for `kind == 'llm'` tiers — see `LlmModelSpec.minRamBytes`.
  final int minRamBytes;

  /// True when device RAM was determined and is below [minRamBytes] — the
  /// download action is disabled and an explanatory string shown.
  final bool ramBlocked;

  /// True when device RAM could not be determined at all — per
  /// `DeviceMemoryInfo`'s doc comment, this tier is left downloadable but
  /// with a storage/memory warning shown instead of a hard block.
  final bool ramUnknown;

  ModelTileState copyWith({ModelTileStatus? status, double? downloadProgress}) => ModelTileState(
    id: id,
    kind: kind,
    displayName: displayName,
    approxSizeBytes: approxSizeBytes,
    isDefault: isDefault,
    status: status ?? this.status,
    downloadProgress: downloadProgress ?? this.downloadProgress,
    minRamBytes: minRamBytes,
    ramBlocked: ramBlocked,
    ramUnknown: ramUnknown,
  );
}
