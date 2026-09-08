import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/data/mappers/job_mappers.dart';
import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';

/// Parses raw `GET /jobs/{id}/ws` JSON frames into [JobUpdateEvent]s.
extension JobUpdateMessageMapper on Map<String, dynamic> {
  /// Returns `null` for an unknown/malformed frame instead of throwing —
  /// a single bad frame must never crash the socket stream. Debug-log only,
  /// matching `LoggingInterceptor`'s `kReleaseMode` gating.
  JobUpdateEvent? toJobUpdateEvent() {
    try {
      final type = this['type'] as String?;
      switch (type) {
        case 'snapshot':
          return JobUpdateEvent.snapshot(
            job: _parseJob(this),
            transcriptText: _parseTranscriptText(this),
            summaryText: _parseSummaryText(this),
            summaryTakeaways: _parseSummaryTakeaways(this),
          );
        case 'status':
          return JobUpdateEvent.status(
            stageIndex: (this['stage_index'] as num?)?.toInt() ?? 0,
            stageTotal: (this['stage_total'] as num?)?.toInt() ?? 0,
            progress: (this['progress'] as num?)?.toDouble(),
            status: this['status'] as String?,
          );
        case 'metadata':
          return JobUpdateEvent.metadata(
            data: Map<String, dynamic>.from(this['data'] as Map? ?? this),
          );
        case 'transcript_word':
          return JobUpdateEvent.transcriptWord(
            index: (this['index'] as num).toInt(),
            word: (this['word'] ?? this['text'] ?? '') as String,
          );
        case 'transcript_done':
          return const JobUpdateEvent.transcriptDone();
        case 'summary_word':
          return JobUpdateEvent.summaryWord(
            index: (this['index'] as num).toInt(),
            word: (this['word'] ?? this['text'] ?? '') as String,
          );
        case 'summary_done':
          return const JobUpdateEvent.summaryDone();
        case 'done':
          return JobUpdateEvent.done(
            job: _parseJob(this),
            transcriptText: _parseTranscriptText(this),
            summaryText: _parseSummaryText(this),
            summaryTakeaways: _parseSummaryTakeaways(this),
          );
        case 'error':
          return JobUpdateEvent.error(
            message: (this['message'] ?? this['detail'] ?? 'error') as String,
            code: this['code'] as String?,
          );
        case 'heartbeat':
          return const JobUpdateEvent.heartbeat();
        case 'pong':
          return const JobUpdateEvent.pong();
        default:
          _log('Unknown WS message type: $type');
          return null;
      }
    } catch (e) {
      _log('Failed to parse WS message: $e');
      return null;
    }
  }

  /// The `snapshot`/`done` `job` payload is REST-shaped plus extra
  /// progress fields (`is_terminal`, `stage_index`, `stage_total`,
  /// `stages`, `progress`) that `JobDetailResponse` doesn't declare —
  /// `json_serializable`'s generated `fromJson` ignores unknown keys, so
  /// the base fields parse through the existing REST model/mapper and the
  /// extra ones are layered on top here.
  JobDetailEntity _parseJob(Map<String, dynamic> frame) {
    final json = frame['job'] as Map<String, dynamic>;
    final base = JobDetailResponse.fromJson(json).toEntity();
    return base.copyWith(
      isTerminal: json['is_terminal'] as bool?,
      stageIndex: (json['stage_index'] as num?)?.toInt(),
      stageTotal: (json['stage_total'] as num?)?.toInt(),
      stages: (json['stages'] as List?)?.map((e) => e.toString()).toList(),
      progress: (json['progress'] as num?)?.toDouble(),
    );
  }

  /// `snapshot`/`done` carry the `transcript`/`summary` objects as siblings
  /// of `job`, not nested inside it — and only the *job* object round-trips
  /// through [JobDetailResponse]. A job already terminal at connect time
  /// gets its full text inlined here (rather than streamed word-by-word,
  /// since there's nothing left to stream), so this must be read
  /// separately or that text is silently lost.
  String? _parseTranscriptText(Map<String, dynamic> frame) {
    final transcript = frame['transcript'] as Map<String, dynamic>?;
    if (transcript == null || transcript['available'] != true) return null;
    return transcript['text'] as String?;
  }

  String? _parseSummaryText(Map<String, dynamic> frame) {
    final summary = frame['summary'] as Map<String, dynamic>?;
    if (summary == null || summary['available'] != true) return null;
    return summary['text'] as String?;
  }

  List<Map<String, dynamic>>? _parseSummaryTakeaways(Map<String, dynamic> frame) {
    final summary = frame['summary'] as Map<String, dynamic>?;
    if (summary == null || summary['available'] != true) return null;
    final takeaways = summary['takeaways'] as List?;
    if (takeaways == null) return null;
    return takeaways.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

void _log(String message) {
  if (!kReleaseMode) debugPrint('[JobUpdatesSocket] $message');
}
