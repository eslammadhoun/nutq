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
    UploadSlot? uploadSlot,
    Transcript? transcript,
    Summary? summary,
  }) = _JobDetailEntity;
}
