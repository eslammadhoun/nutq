// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobDetailResponse {

 String get id; String get status;@JsonKey(name: 'source_type') String get sourceType; String get language;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'error_code') String? get errorCode;@JsonKey(name: 'error_detail') String? get errorDetail;@JsonKey(name: 'upload_slot') UploadSlotResponse? get uploadSlot; TranscriptResponse? get transcript; SummaryResponse? get summary;
/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobDetailResponseCopyWith<JobDetailResponse> get copyWith => _$JobDetailResponseCopyWithImpl<JobDetailResponse>(this as JobDetailResponse, _$identity);

  /// Serializes this JobDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobDetailResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,uploadSlot,transcript,summary);

@override
String toString() {
  return 'JobDetailResponse(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, uploadSlot: $uploadSlot, transcript: $transcript, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $JobDetailResponseCopyWith<$Res>  {
  factory $JobDetailResponseCopyWith(JobDetailResponse value, $Res Function(JobDetailResponse) _then) = _$JobDetailResponseCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'error_code') String? errorCode,@JsonKey(name: 'error_detail') String? errorDetail,@JsonKey(name: 'upload_slot') UploadSlotResponse? uploadSlot, TranscriptResponse? transcript, SummaryResponse? summary
});


$UploadSlotResponseCopyWith<$Res>? get uploadSlot;$TranscriptResponseCopyWith<$Res>? get transcript;$SummaryResponseCopyWith<$Res>? get summary;

}
/// @nodoc
class _$JobDetailResponseCopyWithImpl<$Res>
    implements $JobDetailResponseCopyWith<$Res> {
  _$JobDetailResponseCopyWithImpl(this._self, this._then);

  final JobDetailResponse _self;
  final $Res Function(JobDetailResponse) _then;

/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? uploadSlot = freezed,Object? transcript = freezed,Object? summary = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,uploadSlot: freezed == uploadSlot ? _self.uploadSlot : uploadSlot // ignore: cast_nullable_to_non_nullable
as UploadSlotResponse?,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as TranscriptResponse?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as SummaryResponse?,
  ));
}
/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadSlotResponseCopyWith<$Res>? get uploadSlot {
    if (_self.uploadSlot == null) {
    return null;
  }

  return $UploadSlotResponseCopyWith<$Res>(_self.uploadSlot!, (value) {
    return _then(_self.copyWith(uploadSlot: value));
  });
}/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranscriptResponseCopyWith<$Res>? get transcript {
    if (_self.transcript == null) {
    return null;
  }

  return $TranscriptResponseCopyWith<$Res>(_self.transcript!, (value) {
    return _then(_self.copyWith(transcript: value));
  });
}/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryResponseCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $SummaryResponseCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobDetailResponse].
extension JobDetailResponsePatterns on JobDetailResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobDetailResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _JobDetailResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _JobDetailResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot,  TranscriptResponse? transcript,  SummaryResponse? summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobDetailResponse() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot,_that.transcript,_that.summary);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot,  TranscriptResponse? transcript,  SummaryResponse? summary)  $default,) {final _that = this;
switch (_that) {
case _JobDetailResponse():
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot,_that.transcript,_that.summary);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot,  TranscriptResponse? transcript,  SummaryResponse? summary)?  $default,) {final _that = this;
switch (_that) {
case _JobDetailResponse() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot,_that.transcript,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobDetailResponse implements JobDetailResponse {
  const _JobDetailResponse({required this.id, required this.status, @JsonKey(name: 'source_type') required this.sourceType, required this.language, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'error_code') this.errorCode, @JsonKey(name: 'error_detail') this.errorDetail, @JsonKey(name: 'upload_slot') this.uploadSlot, this.transcript, this.summary});
  factory _JobDetailResponse.fromJson(Map<String, dynamic> json) => _$JobDetailResponseFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override final  String language;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'error_code') final  String? errorCode;
@override@JsonKey(name: 'error_detail') final  String? errorDetail;
@override@JsonKey(name: 'upload_slot') final  UploadSlotResponse? uploadSlot;
@override final  TranscriptResponse? transcript;
@override final  SummaryResponse? summary;

/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobDetailResponseCopyWith<_JobDetailResponse> get copyWith => __$JobDetailResponseCopyWithImpl<_JobDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobDetailResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,uploadSlot,transcript,summary);

@override
String toString() {
  return 'JobDetailResponse(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, uploadSlot: $uploadSlot, transcript: $transcript, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$JobDetailResponseCopyWith<$Res> implements $JobDetailResponseCopyWith<$Res> {
  factory _$JobDetailResponseCopyWith(_JobDetailResponse value, $Res Function(_JobDetailResponse) _then) = __$JobDetailResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'error_code') String? errorCode,@JsonKey(name: 'error_detail') String? errorDetail,@JsonKey(name: 'upload_slot') UploadSlotResponse? uploadSlot, TranscriptResponse? transcript, SummaryResponse? summary
});


@override $UploadSlotResponseCopyWith<$Res>? get uploadSlot;@override $TranscriptResponseCopyWith<$Res>? get transcript;@override $SummaryResponseCopyWith<$Res>? get summary;

}
/// @nodoc
class __$JobDetailResponseCopyWithImpl<$Res>
    implements _$JobDetailResponseCopyWith<$Res> {
  __$JobDetailResponseCopyWithImpl(this._self, this._then);

  final _JobDetailResponse _self;
  final $Res Function(_JobDetailResponse) _then;

/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? uploadSlot = freezed,Object? transcript = freezed,Object? summary = freezed,}) {
  return _then(_JobDetailResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,uploadSlot: freezed == uploadSlot ? _self.uploadSlot : uploadSlot // ignore: cast_nullable_to_non_nullable
as UploadSlotResponse?,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as TranscriptResponse?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as SummaryResponse?,
  ));
}

/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadSlotResponseCopyWith<$Res>? get uploadSlot {
    if (_self.uploadSlot == null) {
    return null;
  }

  return $UploadSlotResponseCopyWith<$Res>(_self.uploadSlot!, (value) {
    return _then(_self.copyWith(uploadSlot: value));
  });
}/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranscriptResponseCopyWith<$Res>? get transcript {
    if (_self.transcript == null) {
    return null;
  }

  return $TranscriptResponseCopyWith<$Res>(_self.transcript!, (value) {
    return _then(_self.copyWith(transcript: value));
  });
}/// Create a copy of JobDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryResponseCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $SummaryResponseCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
