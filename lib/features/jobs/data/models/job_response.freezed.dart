// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobResponse {

 String get id; String get status;@JsonKey(name: 'source_type') String get sourceType; String get language;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'error_code') String? get errorCode;@JsonKey(name: 'error_detail') String? get errorDetail;@JsonKey(name: 'upload_slot') UploadSlotResponse? get uploadSlot;
/// Create a copy of JobResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobResponseCopyWith<JobResponse> get copyWith => _$JobResponseCopyWithImpl<JobResponse>(this as JobResponse, _$identity);

  /// Serializes this JobResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,uploadSlot);

@override
String toString() {
  return 'JobResponse(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, uploadSlot: $uploadSlot)';
}


}

/// @nodoc
abstract mixin class $JobResponseCopyWith<$Res>  {
  factory $JobResponseCopyWith(JobResponse value, $Res Function(JobResponse) _then) = _$JobResponseCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'error_code') String? errorCode,@JsonKey(name: 'error_detail') String? errorDetail,@JsonKey(name: 'upload_slot') UploadSlotResponse? uploadSlot
});


$UploadSlotResponseCopyWith<$Res>? get uploadSlot;

}
/// @nodoc
class _$JobResponseCopyWithImpl<$Res>
    implements $JobResponseCopyWith<$Res> {
  _$JobResponseCopyWithImpl(this._self, this._then);

  final JobResponse _self;
  final $Res Function(JobResponse) _then;

/// Create a copy of JobResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? uploadSlot = freezed,}) {
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
as UploadSlotResponse?,
  ));
}
/// Create a copy of JobResponse
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
}
}


/// Adds pattern-matching-related methods to [JobResponse].
extension JobResponsePatterns on JobResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobResponse value)  $default,){
final _that = this;
switch (_that) {
case _JobResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobResponse value)?  $default,){
final _that = this;
switch (_that) {
case _JobResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobResponse() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot)  $default,) {final _that = this;
switch (_that) {
case _JobResponse():
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'error_code')  String? errorCode, @JsonKey(name: 'error_detail')  String? errorDetail, @JsonKey(name: 'upload_slot')  UploadSlotResponse? uploadSlot)?  $default,) {final _that = this;
switch (_that) {
case _JobResponse() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.uploadSlot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobResponse implements JobResponse {
  const _JobResponse({required this.id, required this.status, @JsonKey(name: 'source_type') required this.sourceType, required this.language, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'error_code') this.errorCode, @JsonKey(name: 'error_detail') this.errorDetail, @JsonKey(name: 'upload_slot') this.uploadSlot});
  factory _JobResponse.fromJson(Map<String, dynamic> json) => _$JobResponseFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override final  String language;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'error_code') final  String? errorCode;
@override@JsonKey(name: 'error_detail') final  String? errorDetail;
@override@JsonKey(name: 'upload_slot') final  UploadSlotResponse? uploadSlot;

/// Create a copy of JobResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobResponseCopyWith<_JobResponse> get copyWith => __$JobResponseCopyWithImpl<_JobResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,uploadSlot);

@override
String toString() {
  return 'JobResponse(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, uploadSlot: $uploadSlot)';
}


}

/// @nodoc
abstract mixin class _$JobResponseCopyWith<$Res> implements $JobResponseCopyWith<$Res> {
  factory _$JobResponseCopyWith(_JobResponse value, $Res Function(_JobResponse) _then) = __$JobResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'error_code') String? errorCode,@JsonKey(name: 'error_detail') String? errorDetail,@JsonKey(name: 'upload_slot') UploadSlotResponse? uploadSlot
});


@override $UploadSlotResponseCopyWith<$Res>? get uploadSlot;

}
/// @nodoc
class __$JobResponseCopyWithImpl<$Res>
    implements _$JobResponseCopyWith<$Res> {
  __$JobResponseCopyWithImpl(this._self, this._then);

  final _JobResponse _self;
  final $Res Function(_JobResponse) _then;

/// Create a copy of JobResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? uploadSlot = freezed,}) {
  return _then(_JobResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,uploadSlot: freezed == uploadSlot ? _self.uploadSlot : uploadSlot // ignore: cast_nullable_to_non_nullable
as UploadSlotResponse?,
  ));
}

/// Create a copy of JobResponse
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
}
}

// dart format on
