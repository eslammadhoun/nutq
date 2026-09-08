import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/whisper_model_spec.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/models/presentation/cubit/model_tile_status.dart';
import 'package:nutq/features/models/presentation/cubit/models_state.dart';

/// Drives the Models screen: the 3 whisper tiers plus install/download
/// status, sourced from [ModelDownloadService] (drift-backed
/// `installed_models` table).
class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit({required this._downloadService}) : super(const ModelsState());

  final ModelDownloadService _downloadService;

  Future<void> loadTiers() async {
    final installed = await _downloadService.listInstalled();
    final installedIds = installed.map((row) => row.modelId).toSet();
    emit(
      state.copyWith(
        tiers: [
          for (final spec in WhisperModelSpec.all)
            ModelTileState(
              id: spec.id,
              displayName: spec.displayName,
              approxSizeBytes: spec.approxSizeBytes,
              isDefault: spec.isDefault,
              status: installedIds.contains(spec.id) ? ModelTileStatus.installed : ModelTileStatus.notInstalled,
            ),
        ],
      ),
    );
  }

  Future<void> download(String modelId) async {
    final spec = WhisperModelSpec.byId(modelId);
    if (spec == null) return;

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
