import 'package:nutq/features/jobs/data/models/job_detail_response.dart';
import 'package:nutq/features/jobs/data/models/job_list_response.dart';
import 'package:nutq/features/jobs/data/models/job_response.dart';
import 'package:nutq/features/jobs/data/models/submit_job_request.dart';
import 'package:nutq/features/jobs/data/models/summary_response.dart';
import 'package:nutq/features/jobs/data/models/transcript_response.dart';
import 'package:nutq/features/jobs/data/models/upload_slot_response.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/entities/upload_slot.dart';

/// Data → domain mappers for the jobs feature. Keeps the repository
/// implementation the only place aware of both layers' types.
extension UploadSlotResponseMapper on UploadSlotResponse {
  UploadSlot toEntity() => UploadSlot(
    uploadUrl: uploadUrl,
    uploadToken: uploadToken,
    expiresInSeconds: expiresInSeconds,
  );
}

extension TranscriptResponseMapper on TranscriptResponse {
  Transcript toEntity() => Transcript(
    language: language,
    wordCount: wordCount,
    durationSeconds: durationSeconds,
    modelName: modelName,
    modelVersion: modelVersion,
    quantization: quantization,
    downloadUrl: downloadUrl,
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

extension JobResponseMapper on JobResponse {
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
    uploadSlot: uploadSlot?.toEntity(),
    preview: preview,
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
    uploadSlot: uploadSlot?.toEntity(),
    transcript: transcript?.toEntity(),
    summary: summary?.toEntity(),
  );
}

extension JobListResponseMapper on JobListResponse {
  JobsPage toEntity() =>
      JobsPage(items: items.map((e) => e.toEntity()).toList(), nextCursor: nextCursor);
}

extension SubmitJobParamsMapper on SubmitJobParams {
  SubmitJobRequest toRequest() => SubmitJobRequest(
    sourceType: sourceType,
    language: language,
    sourceUrl: sourceUrl,
    forceWhisper: forceWhisper,
    text: text,
    filename: filename,
    contentType: contentType,
    sizeHint: sizeHint,
    idempotencyKey: idempotencyKey,
  );
}
