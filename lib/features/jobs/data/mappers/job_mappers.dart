import 'package:drift/drift.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/source_info.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';

/// First [maxLength] characters with whitespace collapsed, ellipsized.
String transcriptPreview(String text, {int maxLength = 140}) {
  final collapsed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (collapsed.length <= maxLength) return collapsed;
  return '${collapsed.substring(0, maxLength).trimRight()}…';
}

extension JobRowMapper on JobRow {
  JobEntity toEntity() => JobEntity(
    id: id,
    status: status,
    sourceType: sourceType,
    sourceLanguage: sourceLanguage,
    createdAt: createdAt,
    updatedAt: updatedAt,
    preview: preview,
    sourceTitle: sourceTitle,
    failureKind: failureKind,
  );
}

extension JobDetailRowsMapper on JobDetailRows {
  JobDetailEntity toEntity() {
    final t = transcript;
    final s = summary;
    return JobDetailEntity(
      id: job.id,
      status: job.status,
      sourceType: job.sourceType,
      sourceLanguage: job.sourceLanguage,
      summaryLanguage: job.summaryLanguage,
      requestedLength: job.requestedLength,
      createdAt: job.createdAt,
      updatedAt: job.updatedAt,
      failureKind: job.failureKind,
      sourceUrl: job.sourceUrl,
      sourceFilePath: job.sourceFilePath,
      sourceMimeType: job.sourceMimeType,
      sourceTitle: job.sourceTitle,
      durationSeconds: job.durationSeconds,
      transcript: t == null
          ? null
          : Transcript(
              text: t.content,
              wordCount: t.wordCount,
              modelName: t.modelName,
              modelVersion: t.modelVersion,
            ),
      summary: s == null
          ? null
          : Summary(
              summaryText: s.summaryText,
              length: job.requestedLength,
              takeaways: s.takeaways,
              modelName: s.modelName,
              promptVersion: s.promptVersion,
              needsReview: s.needsReview,
              tokensIn: s.tokensIn,
              tokensOut: s.tokensOut,
              processingTimeMs: s.processingTimeMs,
            ),
    );
  }
}

extension JobDetailEntityMapper on JobDetailEntity {
  JobsCompanion toJobCompanion() => JobsCompanion.insert(
    id: id,
    status: status,
    sourceType: sourceType,
    sourceLanguage: sourceLanguage,
    summaryLanguage: Value(summaryLanguage),
    requestedLength: requestedLength,
    createdAt: createdAt,
    updatedAt: updatedAt,
    failureKind: Value(failureKind),
    preview: Value(transcript == null ? null : transcriptPreview(transcript!.text)),
    sourceUrl: Value(sourceUrl),
    sourceFilePath: Value(sourceFilePath),
    sourceMimeType: Value(sourceMimeType),
    sourceTitle: Value(sourceTitle),
    durationSeconds: Value(durationSeconds),
  );

  /// Null for jobs that start from media and have no transcript yet.
  JobTranscriptsCompanion? toTranscriptCompanion() => transcript?.toCompanion(id);
}

extension TranscriptMapper on Transcript {
  JobTranscriptsCompanion toCompanion(String jobId) => JobTranscriptsCompanion.insert(
    jobId: jobId,
    content: text,
    wordCount: wordCount,
    modelName: Value(modelName),
    modelVersion: Value(modelVersion),
  );
}

extension SummaryMapper on Summary {
  JobSummariesCompanion toCompanion(String jobId) => JobSummariesCompanion.insert(
    jobId: jobId,
    summaryText: summaryText,
    takeaways: takeaways,
    modelName: modelName,
    promptVersion: promptVersion,
    needsReview: Value(needsReview),
    tokensIn: Value(tokensIn),
    tokensOut: Value(tokensOut),
    processingTimeMs: Value(processingTimeMs),
  );
}

extension SourceInfoMapper on SourceInfo {
  /// Only the fields that are set, so a partial update never erases the rest.
  JobsCompanion toCompanion(DateTime at) => JobsCompanion(
    updatedAt: Value(at),
    sourceTitle: title == null ? const Value.absent() : Value(title),
    sourceFilePath: filePath == null ? const Value.absent() : Value(filePath),
    sourceMimeType: mimeType == null ? const Value.absent() : Value(mimeType),
    durationSeconds: durationSeconds == null ? const Value.absent() : Value(durationSeconds),
  );
}
