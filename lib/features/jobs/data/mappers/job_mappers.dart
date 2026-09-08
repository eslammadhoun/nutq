import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/database/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/data/models/summary_response.dart';
import 'package:nutq/features/jobs/data/models/transcript_response.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';

/// Data → domain mappers for the jobs feature. Keeps the repository
/// implementation the only place aware of both layers' types.
///
/// [TranscriptResponseMapper]/[SummaryResponseMapper]/[JobDetailResponseMapper]
/// below map the legacy WS-frame wire DTOs (`data/models/*_response.dart`)
/// that `job_update_message_mapper.dart` still parses `snapshot`/`done`
/// frames into — that live-update path is out of scope for this workstream
/// and is replaced wholesale by the local orchestrator in a later one.
extension TranscriptResponseMapper on TranscriptResponse {
  Transcript toEntity() => Transcript(
    language: language,
    wordCount: wordCount,
    durationSeconds: durationSeconds,
    modelName: modelName,
    modelVersion: modelVersion,
    quantization: quantization,
    downloadUrl: downloadUrl,
    text: text,
  );
}

extension SummaryResponseMapper on SummaryResponse {
  Summary toEntity() => Summary(
    summaryText: summaryText,
    toneAndFormat: toneAndFormat,
    takeaways: takeaways,
    modelName: modelName,
    promptVersion: promptVersion,
    tokensIn: tokensIn,
    tokensOut: tokensOut,
  );
}

extension JobDetailResponseMapper on JobDetailResponse {
  JobDetailEntity toEntity() => JobDetailEntity(
    id: id,
    status: status,
    sourceType: sourceType,
    language: language,
    createdAt: createdAt,
    updatedAt: updatedAt,
    errorCode: errorCode,
    errorDetail: errorDetail,
    contentType: contentType,
    transcript: transcript?.toEntity(),
    summary: summary?.toEntity(),
  );
}

/// Drift row → domain mappers for the local-DB-backed repository.
extension JobRowMapper on JobRow {
  JobEntity toEntity() => JobEntity(
    id: id,
    status: status,
    sourceType: sourceType,
    language: language,
    createdAt: createdAt,
    updatedAt: updatedAt,
    errorCode: errorCode,
    errorDetail: errorDetail,
    contentType: contentType,
    preview: previewText ?? inlineText,
  );
}

extension TranscriptRowMapper on TranscriptRow {
  Transcript toEntity() => Transcript(
    language: language,
    wordCount: wordCount,
    durationSeconds: durationSeconds,
    modelName: modelName,
    modelVersion: modelVersion,
    quantization: quantization,
    text: content,
  );
}

extension SummaryRowMapper on SummaryRow {
  Summary toEntity(List<TakeawayRow> takeawayRows) => Summary(
    summaryText: summaryText,
    toneAndFormat: toneAndFormat,
    takeaways: takeawayRows.map((t) => {'text': t.content}).toList(),
    modelName: modelName,
    promptVersion: promptVersion,
    tokensIn: tokensIn,
    tokensOut: tokensOut,
  );
}

extension JobDetailRowMapper on JobDetailRow {
  JobDetailEntity toEntity() => JobDetailEntity(
    id: job.id,
    status: job.status,
    sourceType: job.sourceType,
    language: job.language,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
    errorCode: job.errorCode,
    errorDetail: job.errorDetail,
    contentType: job.contentType,
    transcript: transcript?.toEntity(),
    summary: summary?.toEntity(takeaways),
  );
}
