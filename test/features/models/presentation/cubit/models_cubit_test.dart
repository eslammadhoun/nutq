import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/ml/models/device_memory_info.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/model_spec.dart';
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
    ModelSpec spec, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.5);
    reportedProgress.add(0.5);
    return nextDownloadResult ??
        ApiResult.success(
          InstalledModelRow(
            modelId: spec.id,
            kind: spec.kind,
            tier: spec.id,
            filePath: '/models/${spec.fileName}',
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

class _FakeDeviceMemoryInfo implements DeviceMemoryInfo {
  _FakeDeviceMemoryInfo(this._bytes);
  final int? _bytes;

  @override
  Future<int?> totalRamBytes() async => _bytes;
}

void main() {
  group('ModelsCubit', () {
    test('loadTiers reflects installed models from the download service (whisper + llm tiers)', () async {
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
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(8000000000));

      await cubit.loadTiers();

      // 3 whisper tiers + 2 gemma tiers.
      expect(cubit.state.tiers, hasLength(5));
      final small = cubit.state.tiers.firstWhere((t) => t.id == 'small');
      expect(small.status, ModelTileStatus.installed);
      expect(small.kind, 'whisper');
      final base = cubit.state.tiers.firstWhere((t) => t.id == 'base');
      expect(base.status, ModelTileStatus.notInstalled);
      final oneB = cubit.state.tiers.firstWhere((t) => t.id == '1b');
      expect(oneB.kind, 'llm');
      expect(oneB.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });

    test('download success marks the tier installed and reports progress', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(8000000000));
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
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(8000000000));
      await cubit.loadTiers();

      await cubit.download('small');

      final small = cubit.state.tiers.firstWhere((t) => t.id == 'small');
      expect(small.status, ModelTileStatus.notInstalled);
      expect(cubit.state.lastError, isA<DeviceOfflineError>());

      await cubit.close();
    });

    test('cancelDownload delegates to the service and resets the tile', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(8000000000));
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
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(8000000000));
      await cubit.loadTiers();

      await cubit.deleteModel('base');

      expect(service.deletedIds, ['base']);
      final base = cubit.state.tiers.firstWhere((t) => t.id == 'base');
      expect(base.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });

    test('4B tier is RAM-blocked and refuses to download when device RAM is known and below 6GB', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(4000000000));
      await cubit.loadTiers();

      final fourB = cubit.state.tiers.firstWhere((t) => t.id == '4b');
      expect(fourB.ramBlocked, isTrue);
      expect(fourB.ramUnknown, isFalse);

      await cubit.download('4b');

      // Refused before even calling the download service.
      expect(service.reportedProgress, isEmpty);
      final fourBAfter = cubit.state.tiers.firstWhere((t) => t.id == '4b');
      expect(fourBAfter.status, ModelTileStatus.notInstalled);

      await cubit.close();
    });

    test('4B tier is downloadable (with an unknown-RAM warning) when RAM cannot be determined', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(null));
      await cubit.loadTiers();

      final fourB = cubit.state.tiers.firstWhere((t) => t.id == '4b');
      expect(fourB.ramBlocked, isFalse);
      expect(fourB.ramUnknown, isTrue);

      await cubit.download('4b');

      expect(service.reportedProgress, [0.5]);
      final fourBAfter = cubit.state.tiers.firstWhere((t) => t.id == '4b');
      expect(fourBAfter.status, ModelTileStatus.installed);

      await cubit.close();
    });

    test('1B tier has no RAM gate regardless of device RAM', () async {
      final service = _FakeModelDownloadService();
      final cubit = ModelsCubit(downloadService: service, deviceMemoryInfo: _FakeDeviceMemoryInfo(1000000000));
      await cubit.loadTiers();

      final oneB = cubit.state.tiers.firstWhere((t) => t.id == '1b');
      expect(oneB.ramBlocked, isFalse);
      expect(oneB.ramUnknown, isFalse);

      await cubit.close();
    });
  });
}
