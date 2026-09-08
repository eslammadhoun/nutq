import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

/// Polling is now only a safety net — used during the initial WS connect
/// attempt's resilience window and as a fallback once the socket's retry
/// budget is exhausted. Once the socket is healthy, polling stops entirely.
const _pollInterval = Duration(seconds: 3);

class JobDetailCubit extends Cubit<JobDetailState> {
  JobDetailCubit({
    required this._repo,
    required this._jobId,
    required this._socketService,
  }) : super(const JobDetailState()) {
    _fetch();
  }

  final JobsRepository _repo;
  final String _jobId;
  final JobUpdatesSocketService _socketService;

  Timer? _pollTimer;
  StreamSubscription<JobUpdateEvent>? _eventSubscription;
  StreamSubscription<JobConnectionStatus>? _statusSubscription;

  /// Only open the socket once the first HTTP fetch has resolved
  /// successfully — the HTTP path is the fast-first-paint fallback for a WS
  /// handshake that fails outright.
  bool _socketStarted = false;

  /// Reconnect-replay de-dup — owned by the cubit (not the service) so it
  /// survives the service's own internal reconnects.
  int _lastTranscriptIndex = -1;
  int _lastSummaryIndex = -1;

  Future<void> refresh() async {
    if (state.connectionStatus == JobConnectionStatus.disconnected) {
      _openSocket();
    }
    await _fetch();
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: JobDetailStatus.loading));
    final result = await _repo.getJob(_jobId);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(status: JobDetailStatus.success, job: data));
        _applyTranscriptText(data.transcript);
        if (!_socketStarted) {
          _socketStarted = true;
          _openSocket();
        }
      case Failure(:final error):
        emit(state.copyWith(status: JobDetailStatus.failure, lastError: error));
    }
  }

  void _openSocket() {
    unawaited(_eventSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    _eventSubscription = _socketService.connect(_jobId).listen(_onEvent);
    _statusSubscription = _socketService.connectionStatus.listen(_onConnectionStatus);
  }

  void _onConnectionStatus(JobConnectionStatus status) {
    if (isClosed) return;
    emit(state.copyWith(connectionStatus: status));

    if (status == JobConnectionStatus.disconnected) {
      // WS retry budget exhausted — fall back to polling.
      final job = state.job;
      if (job != null) _scheduleNextPoll(job.status);
    } else if (status == JobConnectionStatus.connected) {
      // Socket healthy again — polling is no longer needed.
      _pollTimer?.cancel();
    }
  }

  void _onEvent(JobUpdateEvent event) {
    if (isClosed) return;

    switch (event) {
      case JobUpdateSnapshot(:final job, :final transcriptText, :final summaryText, :final summaryTakeaways):
        // Full-state message — last-write-wins, no merge logic needed.
        // transcriptText/summaryText are only non-null when the job was
        // already terminal at connect time (inlined instead of streamed).
        emit(
          state.copyWith(
            status: JobDetailStatus.success,
            job: job,
            streamingTranscript: transcriptText,
            streamingSummary: summaryText,
            summaryTakeaways: summaryTakeaways,
          ),
        );
        _applyTranscriptText(job.transcript);

      case JobUpdateStatus(:final stageIndex, :final stageTotal, :final progress, :final status):
        final job = state.job;
        if (job == null) return;
        emit(
          state.copyWith(
            job: job.copyWith(
              stageIndex: stageIndex,
              stageTotal: stageTotal,
              progress: progress,
              status: status ?? job.status,
            ),
          ),
        );

      case JobUpdateMetadata():
        // Reserved for future use — no state to fold today.
        break;

      case JobUpdateTranscriptWord(:final index, :final word):
        if (index <= _lastTranscriptIndex) return; // reconnect replay — already applied
        _lastTranscriptIndex = index;
        emit(state.copyWith(streamingTranscript: _appendWord(state.streamingTranscript, word)));

      case JobUpdateTranscriptDone():
        break;

      case JobUpdateSummaryWord(:final index, :final word):
        if (index <= _lastSummaryIndex) return; // reconnect replay — already applied
        _lastSummaryIndex = index;
        emit(state.copyWith(streamingSummary: _appendWord(state.streamingSummary, word)));

      case JobUpdateSummaryDone():
        break;

      case JobUpdateDone(:final job, :final transcriptText, :final summaryText, :final summaryTakeaways):
        emit(
          state.copyWith(
            status: JobDetailStatus.success,
            job: job,
            streamingTranscript: transcriptText,
            streamingSummary: summaryText,
            summaryTakeaways: summaryTakeaways,
          ),
        );
        _applyTranscriptText(job.transcript);
        _teardownSocket();

      case JobUpdateError(:final message, :final code):
        // Match the same ApiError shape/variant the HTTP 404 path produces
        // (ErrorHandler._handleBadResponse falls through to
        // ApiError.server(message, statusCode)) so jobsErrorMessage renders
        // identically regardless of transport.
        final statusCode = code == '4404' ? 404 : null;
        emit(state.copyWith(status: JobDetailStatus.failure, lastError: ApiError.server(message, statusCode)));
        _teardownSocket();

      case JobUpdateHeartbeat():
      case JobUpdatePong():
        break;
    }
  }

  String _appendWord(String? existing, String word) {
    if (existing == null || existing.isEmpty) return word;
    return '$existing $word';
  }

  /// Clean, server-initiated terminal close (`done`/`error` frame) — stop
  /// listening and disconnect for good. No reconnect is attempted.
  void _teardownSocket() {
    unawaited(_eventSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    _eventSubscription = null;
    _statusSubscription = null;
    _pollTimer?.cancel();
    _socketService.disconnect();
  }

  /// Both the REST detail response and the WS `snapshot`/`done` frames
  /// inline the full transcript body directly — prefer that over a
  /// presigned-URL fetch, which is a fallback for the (now rare) case
  /// where the backend hasn't inlined it.
  void _applyTranscriptText(Transcript? transcript) {
    final text = transcript?.text;
    if (text != null) {
      if (state.transcriptText != text) emit(state.copyWith(transcriptText: text));
      return;
    }
    _maybeFetchTranscriptText(transcript?.downloadUrl);
  }

  /// Fallback for a transcript with no inlined [Transcript.text] — fetched
  /// once per job, not on every poll.
  void _maybeFetchTranscriptText(String? downloadUrl) {
    if (downloadUrl == null ||
        state.transcriptText != null ||
        state.isLoadingTranscriptText) {
      return;
    }

    () async {
      emit(state.copyWith(isLoadingTranscriptText: true));
      final result = await _repo.fetchTranscriptText(downloadUrl);
      if (isClosed) return;

      switch (result) {
        case Success(:final data):
          emit(state.copyWith(isLoadingTranscriptText: false, transcriptText: data));
        case Failure():
          emit(state.copyWith(isLoadingTranscriptText: false));
      }
    }();
  }

  void _scheduleNextPoll(String rawStatus) {
    _pollTimer?.cancel();
    final status = Job.statusFromRaw(rawStatus);
    final isTerminal =
        status == JobStatus.done ||
        status == JobStatus.failed ||
        status == JobStatus.cancelled;
    if (isTerminal) return;
    _pollTimer = Timer(_pollInterval, _pollTick);
  }

  Future<void> _pollTick() async {
    final result = await _repo.getJob(_jobId);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(status: JobDetailStatus.success, job: data));
        _applyTranscriptText(data.transcript);
        _scheduleNextPoll(data.status);
      case Failure(:final error):
        emit(state.copyWith(status: JobDetailStatus.failure, lastError: error));
    }
  }

  Future<void> cancelJob() async {
    final job = state.job;
    if (job == null || state.isCancelling) return;

    emit(state.copyWith(isCancelling: true));
    final result = await _repo.cancelJob(job.id);
    if (isClosed) return;

    switch (result) {
      case Success():
        await _fetch(silent: true);
        if (!isClosed) emit(state.copyWith(isCancelling: false));
      case Failure(:final error):
        emit(
          state.copyWith(
            isCancelling: false,
            cancelError: error,
            cancelErrorToken: state.cancelErrorToken + 1,
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    unawaited(_eventSubscription?.cancel());
    unawaited(_statusSubscription?.cancel());
    _socketService.disconnect();
    return super.close();
  }
}
