import 'package:drift/drift.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/features/jobs/data/local/daos/jobs_dao.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';

extension JobRowMapper on JobRow {
  JobEntity toEntity() => JobEntity(
    id: id,
    status: status,
    sourceType: sourceType,
    language: language,
    createdAt: createdAt,
    updatedAt: updatedAt,
    preview: preview,
    failureKind: failureKind,
  );
}

extension JobDetailRowsMapper on JobDetailRows {
  JobDetailEntity toEntity() => JobDetailEntity(
    id: job.id,
    status: job.status,
    sourceType: job.sourceType,
    language: job.language,
    requestedLength: job.requestedLength,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
    failureKind: job.failureKind,
    transcript: transcript == null
        ? null
        : Transcript(
            text: transcript!.content,
            wordCount: transcript!.wordCount,
          ),
    summary: summary == null
        ? null
        : Summary(
            summaryText: summary!.summaryText,
            length: job.requestedLength,
            takeaways: summary!.takeaways,
            modelName: summary!.modelName,
            promptVersion: summary!.promptVersion,
            needsReview: summary!.needsReview,
            tokensIn: summary!.tokensIn,
            tokensOut: summary!.tokensOut,
            processingTimeMs: summary!.processingTimeMs,
          ),
  );
}

extension JobDetailEntityMapper on JobDetailEntity {
  JobsCompanion toJobCompanion() => JobsCompanion.insert(
    id: id,
    status: status,
    sourceType: sourceType,
    language: language,
    requestedLength: requestedLength,
    createdAt: createdAt,
    updatedAt: updatedAt,
    failureKind: Value(failureKind),
    preview: Value(_preview),
  );

  /// Only pasted-text jobs have a transcript to store.
  JobTranscriptsCompanion toTranscriptCompanion() {
    final t = transcript!;
    return JobTranscriptsCompanion.insert(
      jobId: id,
      content: t.text,
      wordCount: t.wordCount,
    );
  }

  String? get _preview =>
      transcript == null ? null : previewOf(transcript!.text);

  /// First [maxLength] characters with whitespace collapsed, ellipsized.
  static String previewOf(String text, {int maxLength = 140}) {
    final collapsed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= maxLength) return collapsed;
    return '${collapsed.substring(0, maxLength).trimRight()}…';
  }
}

extension SummaryMapper on Summary {
  JobSummariesCompanion toCompanion(String jobId) =>
      JobSummariesCompanion.insert(
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
