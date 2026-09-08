import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/daos/jobs_dao.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Local-DB-backed datasource — everything the REST `JobsApiService`
/// (deleted) used to do over the network now happens against [JobsDao].
abstract interface class JobsDataSource {
  Future<ApiResult<JobsPageRows>> listJobs({String? cursor, int limit});
  Future<ApiResult<JobRow>> submitJob(SubmitJobParams params);
  Future<ApiResult<JobDetailRow>> getJob(String jobId);
  Future<ApiResult<JobRow>> cancelJob(String jobId);
  Future<ApiResult<void>> deleteJob(String jobId);
  Future<ApiResult<String>> fetchTranscriptText(String jobId);
}

class JobsDataSourceImpl implements JobsDataSource {
  JobsDataSourceImpl(
    this._dao, {
    Uuid? uuid,
    DateTime Function()? now,
    Future<Directory> Function()? supportDirectory,
  }) : _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now,
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final JobsDao _dao;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Overridable in tests — the real implementation needs a platform
  /// channel (`path_provider`) that isn't available under `flutter test`.
  final Future<Directory> Function() _supportDirectory;

  @override
  Future<ApiResult<JobsPageRows>> listJobs({String? cursor, int limit = 20}) async {
    try {
      final page = await _dao.listJobs(cursor: cursor, limit: limit);
      return ApiResult.success(page);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  @override
  Future<ApiResult<JobRow>> submitJob(SubmitJobParams params) async {
    try {
      final id = _uuid.v4();
      final now = _now();

      String? sourceFilePath;
      final file = params.file;
      if (file != null) {
        sourceFilePath = await _copyToPermanentStorage(id, file.path, file.name);
      }

      await _dao.insertJob(
        JobsCompanion.insert(
          id: id,
          status: 'pending',
          sourceType: params.sourceType,
          language: params.language,
          createdAt: now,
          updatedAt: now,
          contentType: Value(params.contentType),
          previewText: Value(_derivePreview(params)),
          sourceFilePath: Value(sourceFilePath),
          sourceUrl: Value(params.sourceUrl),
          inlineText: Value(params.text),
        ),
      );

      final job = await _dao.getJob(id);
      if (job == null) {
        return const ApiResult.failure(ApiError.unknown('job not found after insert'));
      }
      return ApiResult.success(job);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  @override
  Future<ApiResult<JobDetailRow>> getJob(String jobId) async {
    try {
      final detail = await _dao.getJobDetail(jobId);
      if (detail == null) {
        return const ApiResult.failure(ApiError.server('job not found', 404));
      }
      return ApiResult.success(detail);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  @override
  Future<ApiResult<JobRow>> cancelJob(String jobId) async {
    try {
      final existing = await _dao.getJob(jobId);
      if (existing == null) {
        return const ApiResult.failure(ApiError.server('job not found', 404));
      }
      await _dao.updateJob(
        jobId,
        JobsCompanion(status: const Value('cancelled'), updatedAt: Value(_now())),
      );
      final updated = await _dao.getJob(jobId);
      return ApiResult.success(updated!);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteJob(String jobId) async {
    try {
      final deleted = await _dao.deleteJob(jobId);
      final path = deleted?.sourceFilePath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  @override
  Future<ApiResult<String>> fetchTranscriptText(String jobId) async {
    try {
      final text = await _dao.getTranscriptText(jobId);
      if (text == null) {
        return const ApiResult.failure(ApiError.server('transcript not found', 404));
      }
      return ApiResult.success(text);
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  /// Copies the picker's transient cache file into the app's permanent
  /// documents/support directory, namespaced by job id so re-picking the
  /// same filename twice can't collide.
  Future<String> _copyToPermanentStorage(
    String jobId,
    String sourcePath,
    String originalFilename,
  ) async {
    final supportDir = await _supportDirectory();
    final uploadsDir = Directory(p.join(supportDir.path, 'uploads'));
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }
    final destinationPath = p.join(uploadsDir.path, '${jobId}_$originalFilename');
    final copied = await File(sourcePath).copy(destinationPath);
    return copied.path;
  }

  /// The jobs list shows a short preview for text jobs; upload/url/youtube
  /// jobs have no local content worth previewing before processing.
  String? _derivePreview(SubmitJobParams params) {
    final text = params.text;
    if (text == null || text.isEmpty) return null;
    return text.length > 140 ? '${text.substring(0, 140)}…' : text;
  }
}
