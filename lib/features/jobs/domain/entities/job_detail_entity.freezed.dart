// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_detail_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JobDetailEntity {

 String get id; String get status; String get sourceType; String get language; DateTime get createdAt; DateTime get updatedAt; String? get errorCode; String? get errorDetail; String? get contentType; Transcript? get transcript; Summary? get summary;// Progress fields with no local processing pipeline yet (Workstream 5)
// to populate them — left null/default until then.
 bool? get isTerminal; int? get stageIndex; int? get stageTotal; List<String>? get stages; double? get progress;
/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobDetailEntityCopyWith<JobDetailEntity> get copyWith => _$JobDetailEntityCopyWithImpl<JobDetailEntity>(this as JobDetailEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobDetailEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.isTerminal, isTerminal) || other.isTerminal == isTerminal)&&(identical(other.stageIndex, stageIndex) || other.stageIndex == stageIndex)&&(identical(other.stageTotal, stageTotal) || other.stageTotal == stageTotal)&&const DeepCollectionEquality().equals(other.stages, stages)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,contentType,transcript,summary,isTerminal,stageIndex,stageTotal,const DeepCollectionEquality().hash(stages),progress);

@override
String toString() {
  return 'JobDetailEntity(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, contentType: $contentType, transcript: $transcript, summary: $summary, isTerminal: $isTerminal, stageIndex: $stageIndex, stageTotal: $stageTotal, stages: $stages, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $JobDetailEntityCopyWith<$Res>  {
  factory $JobDetailEntityCopyWith(JobDetailEntity value, $Res Function(JobDetailEntity) _then) = _$JobDetailEntityCopyWithImpl;
@useResult
$Res call({
 String id, String status, String sourceType, String language, DateTime createdAt, DateTime updatedAt, String? errorCode, String? errorDetail, String? contentType, Transcript? transcript, Summary? summary, bool? isTerminal, int? stageIndex, int? stageTotal, List<String>? stages, double? progress
});


$TranscriptCopyWith<$Res>? get transcript;$SummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class _$JobDetailEntityCopyWithImpl<$Res>
    implements $JobDetailEntityCopyWith<$Res> {
  _$JobDetailEntityCopyWithImpl(this._self, this._then);

  final JobDetailEntity _self;
  final $Res Function(JobDetailEntity) _then;

/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? contentType = freezed,Object? transcript = freezed,Object? summary = freezed,Object? isTerminal = freezed,Object? stageIndex = freezed,Object? stageTotal = freezed,Object? stages = freezed,Object? progress = freezed,}) {
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
as String?,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as Transcript?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Summary?,isTerminal: freezed == isTerminal ? _self.isTerminal : isTerminal // ignore: cast_nullable_to_non_nullable
as bool?,stageIndex: freezed == stageIndex ? _self.stageIndex : stageIndex // ignore: cast_nullable_to_non_nullable
as int?,stageTotal: freezed == stageTotal ? _self.stageTotal : stageTotal // ignore: cast_nullable_to_non_nullable
as int?,stages: freezed == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<String>?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranscriptCopyWith<$Res>? get transcript {
    if (_self.transcript == null) {
    return null;
  }

  return $TranscriptCopyWith<$Res>(_self.transcript!, (value) {
    return _then(_self.copyWith(transcript: value));
  });
}/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $SummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobDetailEntity].
extension JobDetailEntityPatterns on JobDetailEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobDetailEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobDetailEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobDetailEntity value)  $default,){
final _that = this;
switch (_that) {
case _JobDetailEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobDetailEntity value)?  $default,){
final _that = this;
switch (_that) {
case _JobDetailEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  Transcript? transcript,  Summary? summary,  bool? isTerminal,  int? stageIndex,  int? stageTotal,  List<String>? stages,  double? progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobDetailEntity() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.transcript,_that.summary,_that.isTerminal,_that.stageIndex,_that.stageTotal,_that.stages,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  Transcript? transcript,  Summary? summary,  bool? isTerminal,  int? stageIndex,  int? stageTotal,  List<String>? stages,  double? progress)  $default,) {final _that = this;
switch (_that) {
case _JobDetailEntity():
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.transcript,_that.summary,_that.isTerminal,_that.stageIndex,_that.stageTotal,_that.stages,_that.progress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String sourceType,  String language,  DateTime createdAt,  DateTime updatedAt,  String? errorCode,  String? errorDetail,  String? contentType,  Transcript? transcript,  Summary? summary,  bool? isTerminal,  int? stageIndex,  int? stageTotal,  List<String>? stages,  double? progress)?  $default,) {final _that = this;
switch (_that) {
case _JobDetailEntity() when $default != null:
return $default(_that.id,_that.status,_that.sourceType,_that.language,_that.createdAt,_that.updatedAt,_that.errorCode,_that.errorDetail,_that.contentType,_that.transcript,_that.summary,_that.isTerminal,_that.stageIndex,_that.stageTotal,_that.stages,_that.progress);case _:
  return null;

}
}

}

/// @nodoc


class _JobDetailEntity implements JobDetailEntity {
  const _JobDetailEntity({required this.id, required this.status, required this.sourceType, required this.language, required this.createdAt, required this.updatedAt, this.errorCode, this.errorDetail, this.contentType, this.transcript, this.summary, this.isTerminal, this.stageIndex, this.stageTotal, final  List<String>? stages, this.progress}): _stages = stages;
  

@override final  String id;
@override final  String status;
@override final  String sourceType;
@override final  String language;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? errorCode;
@override final  String? errorDetail;
@override final  String? contentType;
@override final  Transcript? transcript;
@override final  Summary? summary;
// Progress fields with no local processing pipeline yet (Workstream 5)
// to populate them — left null/default until then.
@override final  bool? isTerminal;
@override final  int? stageIndex;
@override final  int? stageTotal;
 final  List<String>? _stages;
@override List<String>? get stages {
  final value = _stages;
  if (value == null) return null;
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? progress;

/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobDetailEntityCopyWith<_JobDetailEntity> get copyWith => __$JobDetailEntityCopyWithImpl<_JobDetailEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobDetailEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.isTerminal, isTerminal) || other.isTerminal == isTerminal)&&(identical(other.stageIndex, stageIndex) || other.stageIndex == stageIndex)&&(identical(other.stageTotal, stageTotal) || other.stageTotal == stageTotal)&&const DeepCollectionEquality().equals(other._stages, _stages)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,sourceType,language,createdAt,updatedAt,errorCode,errorDetail,contentType,transcript,summary,isTerminal,stageIndex,stageTotal,const DeepCollectionEquality().hash(_stages),progress);

@override
String toString() {
  return 'JobDetailEntity(id: $id, status: $status, sourceType: $sourceType, language: $language, createdAt: $createdAt, updatedAt: $updatedAt, errorCode: $errorCode, errorDetail: $errorDetail, contentType: $contentType, transcript: $transcript, summary: $summary, isTerminal: $isTerminal, stageIndex: $stageIndex, stageTotal: $stageTotal, stages: $stages, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$JobDetailEntityCopyWith<$Res> implements $JobDetailEntityCopyWith<$Res> {
  factory _$JobDetailEntityCopyWith(_JobDetailEntity value, $Res Function(_JobDetailEntity) _then) = __$JobDetailEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String sourceType, String language, DateTime createdAt, DateTime updatedAt, String? errorCode, String? errorDetail, String? contentType, Transcript? transcript, Summary? summary, bool? isTerminal, int? stageIndex, int? stageTotal, List<String>? stages, double? progress
});


@override $TranscriptCopyWith<$Res>? get transcript;@override $SummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class __$JobDetailEntityCopyWithImpl<$Res>
    implements _$JobDetailEntityCopyWith<$Res> {
  __$JobDetailEntityCopyWithImpl(this._self, this._then);

  final _JobDetailEntity _self;
  final $Res Function(_JobDetailEntity) _then;

/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? sourceType = null,Object? language = null,Object? createdAt = null,Object? updatedAt = null,Object? errorCode = freezed,Object? errorDetail = freezed,Object? contentType = freezed,Object? transcript = freezed,Object? summary = freezed,Object? isTerminal = freezed,Object? stageIndex = freezed,Object? stageTotal = freezed,Object? stages = freezed,Object? progress = freezed,}) {
  return _then(_JobDetailEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,transcript: freezed == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as Transcript?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Summary?,isTerminal: freezed == isTerminal ? _self.isTerminal : isTerminal // ignore: cast_nullable_to_non_nullable
as bool?,stageIndex: freezed == stageIndex ? _self.stageIndex : stageIndex // ignore: cast_nullable_to_non_nullable
as int?,stageTotal: freezed == stageTotal ? _self.stageTotal : stageTotal // ignore: cast_nullable_to_non_nullable
as int?,stages: freezed == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<String>?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranscriptCopyWith<$Res>? get transcript {
    if (_self.transcript == null) {
    return null;
  }

  return $TranscriptCopyWith<$Res>(_self.transcript!, (value) {
    return _then(_self.copyWith(transcript: value));
  });
}/// Create a copy of JobDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $SummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
