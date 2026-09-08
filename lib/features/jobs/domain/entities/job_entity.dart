import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_entity.freezed.dart';

/// Domain job summary — list-view shape, backed by a `Jobs` DB row.
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
    String? preview,
  }) = _JobEntity;
}
