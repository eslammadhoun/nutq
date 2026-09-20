import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_exceptions.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/usecases/run_summary_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';

/// One job's detail screen.
///
/// The stored job (from [JobsRepository.watchJob]) is the source of truth for
/// everything durable: status, transcript, summary, failure. On top of it the
/// cubit layers in-memory live state — pipeline progress and the summary as it
/// streams in — which exists only while a run is active.
///
/// Opening a `pending` job starts it. Leaving the screen while it runs cancels
/// it; the cancellation is recorded, so the job never stays "running".
class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit({
    required this._repository,
    required this._runJob,
    required this.jobId,
  }) : super(const JobDetailState()) {
    _watch();
  }

  final JobsRepository _repository;
  final RunSummaryJob _runJob;
  final String jobId;

  static const _partialInterval = Duration(milliseconds: 50);

  StreamSubscription<JobDetailEntity?>? _jobSubscription;
  StreamSubscription<JobRunEvent>? _runSubscription;
  JobRun? _run;

  Timer? _partialTimer;
  String? _latestPartial;
  DateTime _lastPartialEmit = DateTime.fromMillisecondsSinceEpoch(0);

  void _watch() {
    unawaited(_jobSubscription?.cancel());
    _jobSubscription = _repository
        .watchJob(jobId)
        .listen(_onJob, onError: _onLoadError);
  }

  /// Retries loading after a storage error.
  Future<void> refresh() async {
    emit(state.copyWith(status: JobDetailStatus.loading, clearLastError: true));
    _watch();
  }

  void _onJob(JobDetailEntity? job) {
    if (isClosed) return;
    if (job == null) {
      _stopLive();
      emit(state.copyWith(status: JobDetailStatus.notFound, clearLive: true));
      return;
    }

    final settled = job.status.isTerminal;
    if (settled) _stopLive();
    emit(
      JobDetailState(
        status: JobDetailStatus.success,
        job: job,
        isCancelling: settled ? false : state.isCancelling,
        progress: settled ? null : state.progress,
        streamingSummary: settled ? null : state.streamingSummary,
      ),
    );

    if (job.status == JobRunStatus.pending && _run == null) _startRun();
  }

  void _onLoadError(Object _) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: JobDetailStatus.failure,
        lastError: AppError.storage,
      ),
    );
  }

  void _startRun() {
    final run = _run = _runJob(jobId);
    _runSubscription = run.events.listen(
      _onRunEvent,
      // Outcomes are stored and arrive through the job stream; only a broken
      // database is reported here.
      onError: (Object error) {
        if (error is JobNotFoundException) return;
        _onLoadError(error);
      },
    );
  }

  void _onRunEvent(JobRunEvent event) {
    if (isClosed) return;
    switch (event) {
      case JobRunProgress(:final progress):
        emit(state.copyWith(progress: progress));
      case JobRunPartialSummary(:final text):
        _onPartial(text);
    }
  }

  /// Streaming text is throttled so the screen isn't rebuilt on every token.
  void _onPartial(String text) {
    _latestPartial = text;
    final sinceLast = DateTime.now().difference(_lastPartialEmit);
    if (sinceLast >= _partialInterval) {
      _emitPartial();
    } else {
      _partialTimer ??= Timer(_partialInterval - sinceLast, _emitPartial);
    }
  }

  void _emitPartial() {
    _partialTimer?.cancel();
    _partialTimer = null;
    final text = _latestPartial;
    if (text == null || isClosed) return;
    _lastPartialEmit = DateTime.now();
    emit(state.copyWith(streamingSummary: text));
  }

  void _stopLive() {
    _partialTimer?.cancel();
    _partialTimer = null;
    _latestPartial = null;
  }

  Future<void> cancelJob() async {
    final run = _run;
    if (run == null || state.isCancelling) return;
    emit(state.copyWith(isCancelling: true));
    await run.cancel();
  }

  @override
  Future<void> close() async {
    _stopLive();
    // Leaving the screen cancels a running job; the run records that itself
    // when its event subscription is cancelled.
    await _run?.cancel();
    await _runSubscription?.cancel();
    await _jobSubscription?.cancel();
    return super.close();
  }
}
