import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/whisper_model_spec.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/models/presentation/cubit/model_tile_status.dart';
import 'package:nutq/features/models/presentation/cubit/models_cubit.dart';

/// Fakes [ModelDownloadService] by subclassing and overriding every method
/// `ModelsCubit` calls — matching the repo's "fake the injected interface"
/// testing convention. `ModelDownloadService` isn't behind an abstract
/// interface (it's a thin `dio`/`drift` wrapper, not a domain repository),
/// so subclassing is the closest equivalent; the `dio`/`modelsDao`
/// constructor args below are never exercised because every overridden
/// method short-circuits before touching them.
class _FakeModelDownloadService extends ModelDownloadService {
  _FakeModelDownloadService() : super(dio: Dio(), modelsDao: AppDatabase.forTesting(NativeDatabase.memory()).modelsDao);

  List<InstalledModelRow> installed = [];
  ApiResult<InstalledModelRow>? nextDownloadResult;
  final List<double> reportedProgress = [];
  final List<String> cancelledIds = [];
  final List<String> deletedIds = [];

  @override
  Future<List<InstalledModelRow>> listInstalled() async => installed;

  @override
  Future<InstalledModelRow?> getInstalled(String modelId) async {
    for (final row in installed) {
      if (row.modelId == modelId) return row;
    }
    return null;
  }

  @override
  Future<ApiResult<InstalledModelRow>> download(
    WhisperModelSpec spec, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.5);
    reportedProgress.add(0.5);
    return nextDownloadResult ??
        ApiResult.success(
          InstalledModelRow(
            modelId: spec.id,
            kind: 'whisper',
            tier: spec.id,
            filePath: '/models/ggml-${spec.id}.bin',
            downloadedAt: DateTime.utc(2026, 9, 1),
            sizeBytes: spec.approxSizeBytes,
            checksum: 'size:${spec.approxSizeBytes}',
          ),
        );
  }

  @override
  Future<void> cancelDownload(String modelId) async => cancelledIds.add(modelId);

  @override
  Future<void> deleteModel(String modelId) async => deletedIds.add(modelId);
}

void main() {
  group('ModelsCubit', () {
    test('loadTiers reflects installed models from the download service', () async {
      final service = _FakeModelDownloadService()
        ..installed = [
          InstalledModelRow(
            modelId: 'small',
            kind: 'whisper',
            tier: 'small',
            filePath: '/models/ggml-small.bin',
            downloadedAt: DateTime.utc(2026, 9, 1),
            sizeBytes: 488000000,
            checksum: 'size:488000000',
          ),
        ];
      final cubit = ModelsCubit(downloadService: service);

      await cubit.loadTiers();

      expect(cubit.state.tiers, hasLength(3));
      final small = cubit.state.tiers.firstWhere((t) => t.id == 'small');
      expect(small.status, ModelTileStatus.installed);
      final base = cubit.state.tiers.firstWhere((t) => t.id == 'base');
      expect(base.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });

    test('download success marks the tier installed and reports progress', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service);
      await cubit.loadTiers();

      await cubit.download('base');

      final base = cubit.state.tiers.firstWhere((t) => t.id == 'base');
      expect(base.status, ModelTileStatus.installed);
      expect(base.downloadProgress, 1);
      expect(service.reportedProgress, [0.5]);

      await cubit.close();
    });

    test('download failure reverts to notInstalled and carries the raw ApiError', () async {
      final service = _FakeModelDownloadService()
        ..nextDownloadResult = const ApiResult.failure(ApiError.deviceOffline());
      final cubit = ModelsCubit(downloadService: service);
      await cubit.loadTiers();

      await cubit.download('small');

      final small = cubit.state.tiers.firstWhere((t) => t.id == 'small');
      expect(small.status, ModelTileStatus.notInstalled);
      expect(cubit.state.lastError, isA<DeviceOfflineError>());

      await cubit.close();
    });

    test('cancelDownload delegates to the service and resets the tile', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service);
      await cubit.loadTiers();

      await cubit.cancelDownload('medium');

      expect(service.cancelledIds, ['medium']);
      final medium = cubit.state.tiers.firstWhere((t) => t.id == 'medium');
      expect(medium.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });

    test('deleteModel delegates to the service and resets the tile', () async {
      final service = _FakeModelDownloadService()
        ..installed = [
          InstalledModelRow(
            modelId: 'base',
            kind: 'whisper',
            tier: 'base',
            filePath: '/models/ggml-base.bin',
            downloadedAt: DateTime.utc(2026, 9, 1),
            sizeBytes: 148000000,
            checksum: 'size:148000000',
          ),
        ];
      final cubit = ModelsCubit(downloadService: service);
      await cubit.loadTiers();

      await cubit.deleteModel('base');

      expect(service.deletedIds, ['base']);
      final base = cubit.state.tiers.firstWhere((t) => t.id == 'base');
      expect(base.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });
  });
}
