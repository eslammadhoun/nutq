import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/data/models/job_response.dart';

part 'job_list_response.freezed.dart';
part 'job_list_response.g.dart';

@freezed
sealed class JobListResponse with _$JobListResponse {
  const factory JobListResponse({
    required List<JobResponse> items,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _JobListResponse;

  factory JobListResponse.fromJson(Map<String, dynamic> json) =>
      _$JobListResponseFromJson(json);
}
