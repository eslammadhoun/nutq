import 'dart:async';
import 'dart:io';

import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';

/// Source of job ids; injectable so tests are deterministic.
typedef JobIdGenerator = String Function();

/// Source of "now" (always UTC); injectable for tests.
typedef Clock = DateTime Function();

/// Removes an app-owned file; must not throw if the file is already gone.
typedef FileRemover = Future<void> Function(String path);

Future<void> removeFileIfExists(String path) async {
  try {
    await File(path).delete();
  } on PathNotFoundException {
    // Already gone.
  }
}

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(
    this._local, {
    required this._newId,
    Clock? now,
    FileRemover? removeFile,
  }) : _now = now ?? (() => DateTime.now().toUtc()),
       _removeFile = removeFile ?? removeFileIfExists;

  final JobsLocalDataSource _local;
  final JobIdGenerator _newId;
  final Clock _now;
  final FileRemover _removeFile;

  static const _active = {JobRunStatus.pending, JobRunStatus.running};

  @override
  Stream<List<JobEntity>> watchJobs(JobsQuery query) =>
      _guardStream(_local.watchJobs(query));

  @override
  Stream<JobDetailEntity?> watchJob(String id) =>
      _guardStream(_local.watchJob(id));

  @override
  Future<JobDetailEntity?> getJob(String id) => _guard(() => _local.getJob(id));

  @override
  Future<JobDetailEntity> createJob(NewJobDraft draft) async {
    _validate(draft);

    return _guard(() async {
      final now = _now();
      final text = draft.text?.trim();
      final job = JobDetailEntity(
        id: _newId(),
        status: JobRunStatus.pending,
        sourceType: draft.sourceType,
        sourceLanguage: draft.sourceLanguage,
        summaryLanguage: draft.summaryLanguage,
        requestedLength: draft.length,
        createdAt: now,
        updatedAt: now,
        sourceUrl: draft.sourceUrl?.trim(),
        sourceFilePath: draft.sourceFilePath,
        sourceMimeType: draft.sourceMimeType,
        sourceTitle: draft.sourceTitle,
        durationSeconds: draft.durationSeconds,
        transcript: text == null
            ? null
            : Transcript(
                text: text,
                wordCount: text.split(RegExp(r'\s+')).length,
              ),
      );
      await _local.insertJob(job);
      return job;
    });
  }

  /// Each source type must bring the input it is processed from.
  void _validate(NewJobDraft draft) {
    final (String? value, String name) = switch (draft.sourceType) {
      JobSourceType.text => (draft.text, 'text'),
      JobSourceType.youtube => (draft.sourceUrl, 'sourceUrl'),
      JobSourceType.audio || JobSourceType.video => (
        draft.sourceFilePath,
        'sourceFilePath',
      ),
    };
    if (value == null || value.trim().isEmpty) {
      throw ArgumentError.value(
        value,
        name,
        '${draft.sourceType.name} jobs need a non-blank $name',
      );
    }
  }

  @override
  Future<void> markRunning(String id) => _transition(
    id,
    from: const {JobRunStatus.pending},
    to: JobRunStatus.running,
  );

  @override
  Future<void> saveTranscript(String id, Transcript transcript) => _guard(
    () async => _check(
      id,
      await _local.saveTranscript(id, transcript, _now()),
      'save a transcript',
    ),
  );

  @override
  Future<void> updateSourceInfo(String id, SourceInfo info) => _guard(
    () async => _check(
      id,
      await _local.updateSourceInfo(id, info, _now()),
      'update the source',
    ),
  );

  @override
  Future<void> completeJob(String id, Summary summary) => _guard(
    () async =>
        _check(id, await _local.completeJob(id, summary, _now()), 'complete'),
  );

  @override
  Future<void> failJob(String id, JobFailureKind kind) => _transition(
    id,
    from: _active,
    to: JobRunStatus.failed,
    failureKind: kind,
  );

  @override
  Future<void> cancelJob(String id) =>
      _transition(id, from: _active, to: JobRunStatus.cancelled);

  @override
  Future<void> deleteJob(String id) => _guard(() async {
    final filePath = (await _local.getJob(id))?.sourceFilePath;
    await _local.deleteJob(id);
    // After the row: a leftover file is harmless, a row pointing at a missing
    // file is not.
    if (filePath != null) await _removeFile(filePath);
  });

  @override
  Future<int> recoverInterruptedJobs() => _guard(
    () => _local.failActiveJobs(JobFailureKind.interrupted, _now()),
  );

  Future<void> _transition(
    String id, {
    required Set<JobRunStatus> from,
    required JobRunStatus to,
    JobFailureKind? failureKind,
  }) => _guard(() async {
    final outcome = await _local.transition(
      id,
      from: from,
      to: to,
      at: _now(),
      failureKind: failureKind,
    );
    _check(id, outcome, 'move to ${to.name}');
  });

  void _check(String id, TransitionOutcome outcome, String action) =>
      switch (outcome) {
        TransitionOutcome.applied => null,
        TransitionOutcome.notFound => throw JobNotFoundException(id),
        TransitionOutcome.invalidState => throw InvalidJobTransitionException(
          id,
          'cannot $action from the current state',
        ),
      };

  /// Domain exceptions pass through; anything else is a storage failure.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on JobNotFoundException {
      rethrow;
    } on InvalidJobTransitionException {
      rethrow;
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw JobStorageException(e);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> source) => source.transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stack, sink) => sink.addError(
        error is JobStorageException ? error : JobStorageException(error),
        stack,
      ),
    ),
  );
}
