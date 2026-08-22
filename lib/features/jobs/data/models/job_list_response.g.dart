// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobListResponse _$JobListResponseFromJson(Map<String, dynamic> json) =>
    _JobListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => JobResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$JobListResponseToJson(_JobListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
    };
