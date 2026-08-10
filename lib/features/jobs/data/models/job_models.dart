import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_models.g.dart';

@JsonSerializable()
class UploadSlotModel extends Equatable {
  @JsonKey(name: 'upload_url')
  final String uploadUrl;

  @JsonKey(name: 'upload_token')
  final String uploadToken;

  @JsonKey(name: 'expires_in_seconds')
  final int expiresInSeconds;

  const UploadSlotModel({
    required this.uploadUrl,
    required this.uploadToken,
    required this.expiresInSeconds,
  });

  factory UploadSlotModel.fromJson(Map<String, dynamic> json) =>
      _$UploadSlotModelFromJson(json);

  @override
  List<Object?> get props => [uploadUrl, uploadToken, expiresInSeconds];
}

@JsonSerializable()
class JobModel extends Equatable {
  final String id;
  final String status;

  @JsonKey(name: 'source_type')
  final String sourceType;

  final String language;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'error_code')
  final String? errorCode;

  @JsonKey(name: 'error_detail')
  final String? errorDetail;

  @JsonKey(name: 'upload_slot')
  final UploadSlotModel? uploadSlot;

  const JobModel({
    required this.id,
    required this.status,
    required this.sourceType,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    this.errorCode,
    this.errorDetail,
    this.uploadSlot,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  @override
  List<Object?> get props => [
    id,
    status,
    sourceType,
    language,
    createdAt,
    updatedAt,
    errorCode,
    errorDetail,
    uploadSlot,
  ];
}

@JsonSerializable()
class JobListResponseModel extends Equatable {
  final List<JobModel> items;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const JobListResponseModel({required this.items, this.nextCursor});

  factory JobListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$JobListResponseModelFromJson(json);

  @override
  List<Object?> get props => [items, nextCursor];
}

@JsonSerializable(includeIfNull: false)
class SubmitJobRequestModel extends Equatable {
  @JsonKey(name: 'source_type')
  final String sourceType;

  final String language;

  final String? text;

  @JsonKey(name: 'idempotency_key')
  final String? idempotencyKey;

  const SubmitJobRequestModel({
    required this.sourceType,
    this.language = 'ar',
    this.text,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => _$SubmitJobRequestModelToJson(this);

  @override
  List<Object?> get props => [sourceType, language, text, idempotencyKey];
}
