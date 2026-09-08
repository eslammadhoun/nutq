import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/entities/upload_slot.dart';

part 'job_detail_entity.freezed.dart';

/// Domain equivalent of [JobDetailResponse].
@freezed
sealed class JobDetailEntity with _$JobDetailEntity {
  const factory JobDetailEntity({
    required String id,
    required String status,
    required String sourceType,
    required String language,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? errorCode,
    String? errorDetail,
    String? contentType,
    UploadSlot? uploadSlot,
    Transcript? transcript,
    Summary? summary,
    // Progress fields the REST `GET /jobs/{id}` response does not return
    // (verified against `job_detail_response.dart`/`job_mappers.dart`) —
    // populated only via the `/jobs/{id}/ws` live-update stream.
    bool? isTerminal,
    int? stageIndex,
    int? stageTotal,
    List<String>? stages,
    double? progress,
  }) = _JobDetailEntity;
}
