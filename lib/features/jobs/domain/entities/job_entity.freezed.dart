// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JobEntity {

 String get id; String get status; String get sourceType; String get language; DateTime get createdAt; DateTime get updatedAt; String? get errorCode; String? get errorDetail; String? get contentType; UploadSlot? get uploadSlot; String? get preview;
/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobEntityCopyWith<JobEntity> get copyWith => _$JobEntityCopyWithImpl<JobEntity>(this as JobEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,contentType,uploadSlot,preview);

@override
String toString() {
  return 'JobEntity(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, contentType: $contentType, uploadSlot: $uploadSlot, preview: $preview)';
}


}

/// @nodoc
abstract mixin class $JobEntityCopyWith<$Res>  {
  factory $JobEntityCopyWith(JobEntity value, $Res Function(JobEntity) _then) = _$JobEntityCopyWithImpl;
@useResult
$Res call({
 String id, String status, String sourceType, String language, DateTime createdAt, DateTime updatedAt, String? errorCode, String? errorDetail, String? contentType, UploadSlot? uploadSlot, String? preview
});


$UploadSlotCopyWith<$Res>? get uploadSlot;

}
/// @nodoc
class _$JobEntityCopyWithImpl<$Res>
    implements $JobEntityCopyWith<$Res> {
  _$JobEntityCopyWithImpl(this._self, this._then);

  final JobEntity _self;
  final $Res Function(JobEntity) _then;

/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? contentType = freezed,Object? uploadSlot = freezed,Object? preview = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,uploadSlot: freezed == uploadSlot ? _self.uploadSlot : uploadSlot // ignore: cast_nullable_to_non_nullable
as UploadSlot?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadSlotCopyWith<$Res>? get uploadSlot {
    if (_self.uploadSlot == null) {
    return null;
  }

  return $UploadSlotCopyWith<$Res>(_self.uploadSlot!, (value) {
    return _then(_self.copyWith(uploadSlot: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobEntity].
extension JobEntityPatterns on JobEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobEntity value)  $default,){
final _that = this;
switch (_that) {
case _JobEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobEntity value)?  $default,){
final _that = this;
switch (_that) {
case _JobEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  UploadSlot? uploadSlot,  String? preview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobEntity() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.uploadSlot,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  UploadSlot? uploadSlot,  String? preview)  $default,) {final _that = this;
switch (_that) {
case _JobEntity():
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.uploadSlot,_that.preview);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  UploadSlot? uploadSlot,  String? preview)?  $default,) {final _that = this;
switch (_that) {
case _JobEntity() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.uploadSlot,_that.preview);case _:
  return null;

}
}

}

/// @nodoc


class _JobEntity implements JobEntity {
  const _JobEntity({required this.id, required this.status, required this.sourceType, required this.language, required this.createdAt, required this.updatedAt, this.errorCode, this.errorDetail, this.contentType, this.uploadSlot, this.preview});
  

@override final  String id;
@override final  String status;
@override final  String sourceType;
@override final  String language;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? errorCode;
@override final  String? errorDetail;
@override final  String? contentType;
@override final  UploadSlot? uploadSlot;
@override final  String? preview;

/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobEntityCopyWith<_JobEntity> get copyWith => __$JobEntityCopyWithImpl<_JobEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.uploadSlot, uploadSlot) || other.uploadSlot == uploadSlot)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,contentType,uploadSlot,preview);

@override
String toString() {
  return 'JobEntity(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, contentType: $contentType, uploadSlot: $uploadSlot, preview: $preview)';
}


}

/// @nodoc
abstract mixin class _$JobEntityCopyWith<$Res> implements $JobEntityCopyWith<$Res> {
  factory _$JobEntityCopyWith(_JobEntity value, $Res Function(_JobEntity) _then) = __$JobEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String sourceType, String language, DateTime createdAt, DateTime updatedAt, String? errorCode, String? errorDetail, String? contentType, UploadSlot? uploadSlot, String? preview
});


@override $UploadSlotCopyWith<$Res>? get uploadSlot;

}
/// @nodoc
class __$JobEntityCopyWithImpl<$Res>
    implements _$JobEntityCopyWith<$Res> {
  __$JobEntityCopyWithImpl(this._self, this._then);

  final _JobEntity _self;
  final $Res Function(_JobEntity) _then;

/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? contentType = freezed,Object? uploadSlot = freezed,Object? preview = freezed,}) {
  return _then(_JobEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,uploadSlot: freezed == uploadSlot ? _self.uploadSlot : uploadSlot // ignore: cast_nullable_to_non_nullable
as UploadSlot?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of JobEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadSlotCopyWith<$Res>? get uploadSlot {
    if (_self.uploadSlot == null) {
    return null;
  }

  return $UploadSlotCopyWith<$Res>(_self.uploadSlot!, (value) {
    return _then(_self.copyWith(uploadSlot: value));
  });
}
}

// dart format on
