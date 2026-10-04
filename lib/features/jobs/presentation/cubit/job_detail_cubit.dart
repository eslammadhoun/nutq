import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';

/// One job's detail screen.
///
/// The stored job (from [JobsRepository.watchJob]) is the source of truth for
/// everything durable: status, transcript, summary, failure. On top of it the
/// cubit layers the job's live state from the [JobScheduler] — progress and the
/// summary as it streams in — which exists only while the job is processed.
///
/// The screen only observes: processing is owned by the scheduler, so leaving
/// the screen never stops a job. [cancelJob] does.
class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit({
    required this._repository,
    required this._scheduler,
    required this.jobId,
  }) : super(const JobDetailState()) {
    _watch();
  }

  final JobsRepository _repository;
  final JobScheduler _scheduler;
  final String jobId;

  StreamSubscription<JobDetailEntity?>? _jobSubscription;
  StreamSubscription<JobLive?>? _liveSubscription;

  void _watch() {
    unawaited(_jobSubscription?.cancel());
    unawaited(_liveSubscription?.cancel());
    _jobSubscription = _repository.watchJob(jobId).listen(_onJob, onError: _onLoadError);
    _liveSubscription = _scheduler.watchLive(jobId).listen(_onLive);
  }

  /// Retries loading after a storage error.
  Future<void> refresh() async {
    emit(state.copyWith(status: JobDetailStatus.loading, clearLastError: true));
    _watch();
  }

  void _onJob(JobDetailEntity? job) {
    if (isClosed) return;
    if (job == null) {
      emit(state.copyWith(status: JobDetailStatus.notFound, clearLive: true));
      return;
    }
    final settled = job.status.isTerminal;
    emit(
      JobDetailState(
        status: JobDetailStatus.success,
        job: job,
        isCancelling: settled ? false : state.isCancelling,
        progress: settled ? null : state.progress,
        streamingSummary: settled ? null : state.streamingSummary,
      ),
    );
  }

  void _onLive(JobLive? live) {
    if (isClosed) return;
    if (live == null) {
      emit(state.copyWith(clearLive: true));
    } else {
      emit(state.copyWith(progress: live.progress, streamingSummary: live.partialSummary));
    }
  }

  void _onLoadError(Object _) {
    if (isClosed) return;
    emit(state.copyWith(status: JobDetailStatus.failure, lastError: AppError.storage));
  }

  Future<void> cancelJob() async {
    if (state.isCancelling) return;
    emit(state.copyWith(isCancelling: true));
    await _scheduler.cancel(jobId);
  }

  @override
  Future<void> close() async {
    await _jobSubscription?.cancel();
    await _liveSubscription?.cancel();
    return super.close();
  }
}
