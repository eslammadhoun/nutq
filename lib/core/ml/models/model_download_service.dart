import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/daos/models_dao.dart';
import 'package:nutq/core/ml/models/model_spec.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

/// Download progress for a single model, 0.0–1.0.
typedef ModelDownloadProgress = double;

/// Downloads a model tier — whisper GGML ([WhisperModelSpec]) or Gemma GGUF
/// (`LlmModelSpec`), anything implementing [ModelSpec] — verifies it,
/// stores it under `getApplicationSupportDirectory()/models/`, and records
/// the result in the `installed_models` table via [ModelsDao]. One
/// download/verify/DB-record path for every model kind — the
/// `installed_models.kind` column (populated from [ModelSpec.kind]) is what
/// tells whisper and llm rows apart, not a second copy of this class.
///
/// Uses `dio` (already a dependency) rather than `http`/`dart:io` directly,
/// matching the rest of the app's network stack, and reports progress so a
/// `ModelsCubit` can drive a progress bar.
class ModelDownloadService {
  ModelDownloadService({required this._dio, required this._modelsDao, this.supportDirectory});

  final Dio _dio;
  final ModelsDao _modelsDao;

  /// Injectable for tests; defaults to the real app-support directory.
  final Future<Directory> Function()? supportDirectory;

  final Map<String, CancelToken> _activeDownloads = {};

  Future<Directory> _modelsDir() async {
    final dir = supportDirectory != null
        ? await supportDirectory!()
        : await path_provider.getApplicationSupportDirectory();
    final modelsDir = Directory(p.join(dir.path, 'models'));
    await modelsDir.create(recursive: true);
    return modelsDir;
  }

  Future<InstalledModelRow?> getInstalled(String modelId) => _modelsDao.getInstalled(modelId);

  Future<List<InstalledModelRow>> listInstalled() => _modelsDao.listInstalled();

  /// Downloads [spec] with progress reporting on [onProgress]. Cancel an
  /// in-flight download for the same model id with [cancel].
  ///
  /// Verification is size-based: the Hugging Face mirror this app
  /// downloads from does not publish a per-file checksum in a
  /// machine-readable form alongside the model, so this checks the
  /// downloaded byte count is within a small tolerance of the expected
  /// `Content-Length` (and non-zero) rather than a cryptographic hash. If a
  /// checksum ever becomes available it should replace this check outright
  /// (see [InstalledModelRow.checksum], currently populated with a
  /// `size:<bytes>` sentinel to make the verification method explicit to
  /// readers of the stored row).
  Future<ApiResult<InstalledModelRow>> download(
    ModelSpec spec, {
    void Function(ModelDownloadProgress progress)? onProgress,
  }) async {
    final cancelToken = CancelToken();
    _activeDownloads[spec.id] = cancelToken;

    try {
      final dir = await _modelsDir();
      final destination = File(p.join(dir.path, spec.fileName));
      final tempFile = File('${destination.path}.part');

      int? expectedBytes;
      await _dio.download(
        spec.downloadUrl.toString(),
        tempFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            expectedBytes = total;
            onProgress?.call(received / total);
          }
        },
      );

      final actualBytes = await tempFile.length();
      final sanityFloor = expectedBytes ?? (spec.approxSizeBytes * 0.8).round();
      if (actualBytes <= 0 || actualBytes < sanityFloor * 0.95) {
        await tempFile.delete();
        return const ApiResult.failure(ApiError.unknown('downloaded model file failed size verification'));
      }

      if (await destination.exists()) await destination.delete();
      await tempFile.rename(destination.path);

      final row = InstalledModelRow(
        modelId: spec.id,
        kind: spec.kind,
        tier: spec.id,
        filePath: destination.path,
        downloadedAt: DateTime.now(),
        sizeBytes: actualBytes,
        checksum: 'size:$actualBytes',
      );
      await _modelsDao.upsert(
        InstalledModelsCompanion.insert(
          modelId: row.modelId,
          kind: row.kind,
          tier: row.tier,
          filePath: row.filePath,
          downloadedAt: row.downloadedAt,
          sizeBytes: row.sizeBytes,
          checksum: row.checksum,
        ),
      );
      return ApiResult.success(row);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const ApiResult.failure(ApiError.processingCancelled());
      }
      if (e.type == DioExceptionType.connectionError) {
        return const ApiResult.failure(ApiError.deviceOffline());
      }
      return ApiResult.failure(ApiError.unknown(e.message ?? 'download failed'));
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    } finally {
      _activeDownloads.remove(spec.id);
    }
  }

  Future<void> cancelDownload(String modelId) async {
    _activeDownloads[modelId]?.cancel('user requested cancel');
  }

  Future<void> deleteModel(String modelId) async {
    final row = await _modelsDao.getInstalled(modelId);
    if (row == null) return;
    final file = File(row.filePath);
    if (await file.exists()) await file.delete();
    await _modelsDao.deleteModel(modelId);
  }
}
