import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/upload_slot.dart';

part 'job_entity.freezed.dart';

/// Domain equivalent of [JobResponse].
@freezed
sealed class JobEntity with _$JobEntity {
  const factory JobEntity({
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
    String? preview,
  }) = _JobEntity;
}
