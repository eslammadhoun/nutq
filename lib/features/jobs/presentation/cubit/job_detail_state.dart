import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';

enum JobDetailStatus { loading, success, failure }

@immutable
class JobDetailState {
  const JobDetailState({
    this.status = JobDetailStatus.loading,
    this.job,
    this.lastError,
    this.isCancelling = false,
    this.cancelError,
    this.cancelErrorToken = 0,
    this.transcriptText,
    this.isLoadingTranscriptText = false,
    this.connectionStatus = JobConnectionStatus.idle,
    this.streamingTranscript,
    this.streamingSummary,
    this.summaryTakeaways,
  });

  final JobDetailStatus status;
  final JobDetailEntity? job;

  /// Raw error from the last failed fetch — localized at display time via
  /// `context.l10n.jobsErrorMessage(error)` (cubits have no BuildContext).
  final ApiError? lastError;

  final bool isCancelling;

  /// Raw error from the last failed cancel — a transient signal for a
  /// one-off SnackBar, paired with [cancelErrorToken] (bumped on every
  /// failure) so the UI's `listenWhen` still fires when the same error
  /// repeats back to back.
  final ApiError? cancelError;
  final int cancelErrorToken;

  /// Body fetched from `job.transcript.downloadUrl` — the detail endpoint
  /// itself only carries transcript metadata, not the text. Fetched once
  /// and cached here rather than re-requested on every poll tick. Prefer
  /// [streamingTranscript] when it's non-null — live word-by-word text
  /// from the WebSocket supersedes this once the socket is connected.
  final String? transcriptText;
  final bool isLoadingTranscriptText;

  /// Live status of the `/jobs/{id}/ws` socket — drives the "Reconnecting…"
  /// indicator and whether the polling fallback is engaged.
  final JobConnectionStatus connectionStatus;

  /// Transcript text streamed word-by-word over the socket. Non-null once
  /// the first `transcript_word` event has arrived; takes precedence over
  /// [transcriptText] in the UI.
  final String? streamingTranscript;

  /// Summary text streamed word-by-word over the socket. Non-null once the
  /// first `summary_word` event has arrived; takes precedence over the
  /// fetched `job.summary.summaryText` in the UI.
  final String? streamingSummary;

  /// Takeaways carried by the terminal `snapshot`/`done` job payload —
  /// mirrors `job.summary.takeaways` but kept separately so it survives a
  /// `metadata` update that doesn't touch `job`.
  final List<Map<String, dynamic>>? summaryTakeaways;

  JobDetailState copyWith({
    JobDetailStatus? status,
    JobDetailEntity? job,
    ApiError? lastError,
    bool? isCancelling,
    ApiError? cancelError,
    int? cancelErrorToken,
    String? transcriptText,
    bool? isLoadingTranscriptText,
    JobConnectionStatus? connectionStatus,
    String? streamingTranscript,
    String? streamingSummary,
    List<Map<String, dynamic>>? summaryTakeaways,
  }) {
    return JobDetailState(
      status: status ?? this.status,
      job: job ?? this.job,
      lastError: lastError,
      isCancelling: isCancelling ?? this.isCancelling,
      cancelError: cancelError ?? this.cancelError,
      cancelErrorToken: cancelErrorToken ?? this.cancelErrorToken,
      transcriptText: transcriptText ?? this.transcriptText,
      isLoadingTranscriptText: isLoadingTranscriptText ?? this.isLoadingTranscriptText,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      streamingTranscript: streamingTranscript ?? this.streamingTranscript,
      streamingSummary: streamingSummary ?? this.streamingSummary,
      summaryTakeaways: summaryTakeaways ?? this.summaryTakeaways,
    );
  }
}
