import 'dart:async';

import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_query.dart';
import 'package:nutq/features/jobs/domain/entities/new_job_draft.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/summarization/data/prompts/prompt_version.dart';
import 'package:nutq/features/jobs/domain/entities/job_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summary_result.dart';

/// Source of job ids; injectable so tests are deterministic.
typedef JobIdGenerator = String Function();

/// Source of "now" (always UTC); injectable for tests.
typedef Clock = DateTime Function();

class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._local, {required this._newId, Clock? now})
    : _now = now ?? (() => DateTime.now().toUtc());

  final JobsLocalDataSource _local;
  final JobIdGenerator _newId;
  final Clock _now;

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
    final text = draft.text.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(draft.text, 'draft.text', 'must not be blank');
    }

    return _guard(() async {
      final now = _now();
      final job = JobDetailEntity(
        id: _newId(),
        status: JobRunStatus.pending,
        sourceType: draft.sourceType,
        language: draft.language,
        requestedLength: draft.length,
        createdAt: now,
        updatedAt: now,
        transcript: Transcript(
          text: text,
          wordCount: text.split(RegExp(r'\s+')).length,
        ),
      );
      await _local.insertJob(job);
      return job;
    });
  }

  @override
  Future<void> markRunning(String id) => _transition(
    id,
    from: const {JobRunStatus.pending},
    to: JobRunStatus.running,
  );

  @override
  Future<void> completeJob(String id, SummaryResult result) => _guard(() async {
    final job = await _local.getJob(id);
    if (job == null) throw JobNotFoundException(id);

    final summary = Summary(
      summaryText: result.summary,
      length: job.requestedLength,
      takeaways: List.unmodifiable(result.keyPoints),
      modelName: summarizationModelId,
      promptVersion: summarizationPromptVersion,
      needsReview: result.validation.isSuspicious,
      tokensIn: result.debug.inputTokens,
      tokensOut: result.debug.outputTokens,
      processingTimeMs: result.debug.processingTimeMs,
    );
    _check(id, await _local.completeJob(id, summary, _now()), 'complete');
  });

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
  Future<void> deleteJob(String id) => _guard(() => _local.deleteJob(id));

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
