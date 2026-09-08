import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/ml/models/device_memory_info.dart';
import 'package:nutq/core/ml/models/llm_model_spec.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/model_spec.dart';
import 'package:nutq/core/ml/models/whisper_model_spec.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/models/presentation/cubit/model_tile_status.dart';
import 'package:nutq/features/models/presentation/cubit/models_state.dart';

/// Drives the Models screen: the whisper ASR tiers and the Gemma
/// summarization tiers, plus install/download status, sourced from
/// [ModelDownloadService] (drift-backed `installed_models` table, shared
/// across both model kinds — see that class's doc comment).
class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit({required this._downloadService, DeviceMemoryInfo? deviceMemoryInfo})
    : _deviceMemoryInfo = deviceMemoryInfo ?? const DeviceMemoryInfoImpl(),
      super(const ModelsState());

  final ModelDownloadService _downloadService;
  final DeviceMemoryInfo _deviceMemoryInfo;

  Future<void> loadTiers() async {
    final installed = await _downloadService.listInstalled();
    final installedIds = installed.map((row) => row.modelId).toSet();
    final ramBytes = await _deviceMemoryInfo.totalRamBytes();

    emit(
      state.copyWith(
        tiers: [
          for (final spec in WhisperModelSpec.all)
            ModelTileState(
              id: spec.id,
              kind: spec.kind,
              displayName: spec.displayName,
              approxSizeBytes: spec.approxSizeBytes,
              isDefault: spec.isDefault,
              status: installedIds.contains(spec.id) ? ModelTileStatus.installed : ModelTileStatus.notInstalled,
            ),
          for (final spec in LlmModelSpec.all)
            ModelTileState(
              id: spec.id,
              kind: spec.kind,
              displayName: spec.displayName,
              approxSizeBytes: spec.approxSizeBytes,
              isDefault: spec.isDefault,
              status: installedIds.contains(spec.id) ? ModelTileStatus.installed : ModelTileStatus.notInstalled,
              minRamBytes: spec.minRamBytes,
              ramBlocked: spec.minRamBytes > 0 && ramBytes != null && ramBytes < spec.minRamBytes,
              ramUnknown: spec.minRamBytes > 0 && ramBytes == null,
            ),
        ],
      ),
    );
  }

  ModelSpec? _specFor(String modelId) => WhisperModelSpec.byId(modelId) ?? LlmModelSpec.byId(modelId);

  Future<void> download(String modelId) async {
    final spec = _specFor(modelId);
    if (spec == null) return;

    // RAM-gated tiers refuse the download outright when we positively know
    // the device doesn't meet the floor; an *unknown* reading is allowed
    // through with only a warning (see `DeviceMemoryInfo`'s doc comment).
    final tile = state.tiers.where((t) => t.id == modelId).firstOrNull;
    if (tile != null && tile.ramBlocked) return;

    _updateTile(modelId, (t) => t.copyWith(status: ModelTileStatus.downloading, downloadProgress: 0));

    final result = await _downloadService.download(
      spec,
      onProgress: (progress) {
        _updateTile(modelId, (t) => t.copyWith(downloadProgress: progress));
      },
    );

    switch (result) {
      case Success():
        _updateTile(modelId, (t) => t.copyWith(status: ModelTileStatus.installed, downloadProgress: 1));
      case Failure(:final error):
        _updateTile(modelId, (t) => t.copyWith(status: ModelTileStatus.notInstalled, downloadProgress: 0));
        emit(state.copyWith(lastError: error));
    }
  }

  Future<void> cancelDownload(String modelId) async {
    await _downloadService.cancelDownload(modelId);
    _updateTile(modelId, (t) => t.copyWith(status: ModelTileStatus.notInstalled, downloadProgress: 0));
  }

  Future<void> deleteModel(String modelId) async {
    await _downloadService.deleteModel(modelId);
    _updateTile(modelId, (t) => t.copyWith(status: ModelTileStatus.notInstalled, downloadProgress: 0));
  }

  void clearError() => emit(state.copyWith(clearError: true));

  void _updateTile(String modelId, ModelTileState Function(ModelTileState) update) {
    emit(
      state.copyWith(
        tiers: [for (final t in state.tiers) if (t.id == modelId) update(t) else t],
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
