import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';

part 'job_update_event.freezed.dart';

/// One message frame from the `GET /jobs/{id}/ws` live-update stream.
///
/// Hand-written sealed union (not `@JsonSerializable`, matching
/// [JobDetailEntity]/`Transcript`/`Summary`) — parsing from the raw JSON
/// frame happens in `job_update_message_mapper.dart`, keeping this file a
/// pure domain shape.
@freezed
sealed class JobUpdateEvent with _$JobUpdateEvent {
  /// Sent once right after connect — full job state, last-write-wins.
  ///
  /// [transcriptText]/[summaryText]/[summaryTakeaways] are non-null only
  /// when the job was already terminal at connect time — the backend
  /// inlines the full text in this frame instead of streaming
  /// word-by-word, since there's nothing left to stream.
  const factory JobUpdateEvent.snapshot({
    required JobDetailEntity job,
    String? transcriptText,
    String? summaryText,
    List<Map<String, dynamic>>? summaryTakeaways,
  }) = JobUpdateSnapshot;

  /// Pipeline stage progress.
  const factory JobUpdateEvent.status({
    required int stageIndex,
    required int stageTotal,
    double? progress,
    String? status,
  }) = JobUpdateStatus;

  /// Free-form metadata payload (backend-controlled shape).
  const factory JobUpdateEvent.metadata({required Map<String, dynamic> data}) =
      JobUpdateMetadata;

  /// One transcript word. [index] is a running counter used for
  /// reconnect de-dup — the server replays its event stream from the
  /// start on every reconnect.
  const factory JobUpdateEvent.transcriptWord({required int index, required String word}) =
      JobUpdateTranscriptWord;

  const factory JobUpdateEvent.transcriptDone() = JobUpdateTranscriptDone;

  const factory JobUpdateEvent.summaryWord({required int index, required String word}) =
      JobUpdateSummaryWord;

  const factory JobUpdateEvent.summaryDone() = JobUpdateSummaryDone;

  /// Terminal — full final job state. Server closes the socket right
  /// after sending this. Carries the full transcript/summary text inline
  /// (see [JobUpdateSnapshot]).
  const factory JobUpdateEvent.done({
    required JobDetailEntity job,
    String? transcriptText,
    String? summaryText,
    List<Map<String, dynamic>>? summaryTakeaways,
  }) = JobUpdateDone;

  /// Terminal — pipeline/server error. Server closes the socket right
  /// after sending this.
  const factory JobUpdateEvent.error({required String message, String? code}) = JobUpdateError;

  const factory JobUpdateEvent.heartbeat() = JobUpdateHeartbeat;

  const factory JobUpdateEvent.pong() = JobUpdatePong;
}
