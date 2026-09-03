// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_job_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewJobState {

 NewJobSourceType get sourceType; JobLanguage get language; String get text; UploadFile? get pickedFile; String get sourceUrl; bool get forceWhisper; bool get idempotencyEnabled; String? get idempotencyKey; bool get fileTooLarge; NewJobStatus get status; ApiError? get lastError; String? get submittedJobId;
/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewJobStateCopyWith<NewJobState> get copyWith => _$NewJobStateCopyWithImpl<NewJobState>(this as NewJobState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewJobState&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.text, text) || other.text == text)&&(identical(other.pickedFile, pickedFile) || other.pickedFile == pickedFile)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.idempotencyEnabled, idempotencyEnabled) || other.idempotencyEnabled == idempotencyEnabled)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.fileTooLarge, fileTooLarge) || other.fileTooLarge == fileTooLarge)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.submittedJobId, submittedJobId) || other.submittedJobId == submittedJobId));
}


@override
int get hashCode => Object.hash(runtimeType,sourceType,language,text,pickedFile,sourceUrl,forceWhisper,idempotencyEnabled,idempotencyKey,fileTooLarge,status,lastError,submittedJobId);

@override
String toString() {
  return 'NewJobState(sourceType: $sourceType, language: $language, text: $text, pickedFile: $pickedFile, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, idempotencyEnabled: $idempotencyEnabled, idempotencyKey: $idempotencyKey, fileTooLarge: $fileTooLarge, status: $status, lastError: $lastError, submittedJobId: $submittedJobId)';
}


}

/// @nodoc
abstract mixin class $NewJobStateCopyWith<$Res>  {
  factory $NewJobStateCopyWith(NewJobState value, $Res Function(NewJobState) _then) = _$NewJobStateCopyWithImpl;
@useResult
$Res call({
 NewJobSourceType sourceType, JobLanguage language, String text, UploadFile? pickedFile, String sourceUrl, bool forceWhisper, bool idempotencyEnabled, String? idempotencyKey, bool fileTooLarge, NewJobStatus status, ApiError? lastError, String? submittedJobId
});


$UploadFileCopyWith<$Res>? get pickedFile;$ApiErrorCopyWith<$Res>? get lastError;

}
/// @nodoc
class _$NewJobStateCopyWithImpl<$Res>
    implements $NewJobStateCopyWith<$Res> {
  _$NewJobStateCopyWithImpl(this._self, this._then);

  final NewJobState _self;
  final $Res Function(NewJobState) _then;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceType = null,Object? language = null,Object? text = null,Object? pickedFile = freezed,Object? sourceUrl = null,Object? forceWhisper = null,Object? idempotencyEnabled = null,Object? idempotencyKey = freezed,Object? fileTooLarge = null,Object? status = null,Object? lastError = freezed,Object? submittedJobId = freezed,}) {
  return _then(_self.copyWith(
sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as NewJobSourceType,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as JobLanguage,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,pickedFile: freezed == pickedFile ? _self.pickedFile : pickedFile // ignore: cast_nullable_to_non_nullable
as UploadFile?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,forceWhisper: null == forceWhisper ? _self.forceWhisper : forceWhisper // ignore: cast_nullable_to_non_nullable
as bool,idempotencyEnabled: null == idempotencyEnabled ? _self.idempotencyEnabled : idempotencyEnabled // ignore: cast_nullable_to_non_nullable
as bool,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,fileTooLarge: null == fileTooLarge ? _self.fileTooLarge : fileTooLarge // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NewJobStatus,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as ApiError?,submittedJobId: freezed == submittedJobId ? _self.submittedJobId : submittedJobId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadFileCopyWith<$Res>? get pickedFile {
    if (_self.pickedFile == null) {
    return null;
  }

  return $UploadFileCopyWith<$Res>(_self.pickedFile!, (value) {
    return _then(_self.copyWith(pickedFile: value));
  });
}/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<$Res>? get lastError {
    if (_self.lastError == null) {
    return null;
  }

  return $ApiErrorCopyWith<$Res>(_self.lastError!, (value) {
    return _then(_self.copyWith(lastError: value));
  });
}
}


/// Adds pattern-matching-related methods to [NewJobState].
extension NewJobStatePatterns on NewJobState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewJobState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewJobState value)  $default,){
final _that = this;
switch (_that) {
case _NewJobState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewJobState value)?  $default,){
final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NewJobSourceType sourceType,  JobLanguage language,  String text,  UploadFile? pickedFile,  String sourceUrl,  bool forceWhisper,  bool idempotencyEnabled,  String? idempotencyKey,  bool fileTooLarge,  NewJobStatus status,  ApiError? lastError,  String? submittedJobId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
return $default(_that.sourceType,_that.language,_that.text,_that.pickedFile,_that.sourceUrl,_that.forceWhisper,_that.idempotencyEnabled,_that.idempotencyKey,_that.fileTooLarge,_that.status,_that.lastError,_that.submittedJobId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NewJobSourceType sourceType,  JobLanguage language,  String text,  UploadFile? pickedFile,  String sourceUrl,  bool forceWhisper,  bool idempotencyEnabled,  String? idempotencyKey,  bool fileTooLarge,  NewJobStatus status,  ApiError? lastError,  String? submittedJobId)  $default,) {final _that = this;
switch (_that) {
case _NewJobState():
return $default(_that.sourceType,_that.language,_that.text,_that.pickedFile,_that.sourceUrl,_that.forceWhisper,_that.idempotencyEnabled,_that.idempotencyKey,_that.fileTooLarge,_that.status,_that.lastError,_that.submittedJobId);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NewJobSourceType sourceType,  JobLanguage language,  String text,  UploadFile? pickedFile,  String sourceUrl,  bool forceWhisper,  bool idempotencyEnabled,  String? idempotencyKey,  bool fileTooLarge,  NewJobStatus status,  ApiError? lastError,  String? submittedJobId)?  $default,) {final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
return $default(_that.sourceType,_that.language,_that.text,_that.pickedFile,_that.sourceUrl,_that.forceWhisper,_that.idempotencyEnabled,_that.idempotencyKey,_that.fileTooLarge,_that.status,_that.lastError,_that.submittedJobId);case _:
  return null;

}
}

}

/// @nodoc


class _NewJobState extends NewJobState {
  const _NewJobState({this.sourceType = NewJobSourceType.text, this.language = JobLanguage.ar, this.text = '', this.pickedFile, this.sourceUrl = '', this.forceWhisper = false, this.idempotencyEnabled = true, this.idempotencyKey, this.fileTooLarge = false, this.status = NewJobStatus.idle, this.lastError, this.submittedJobId}): super._();
  

@override@JsonKey() final  NewJobSourceType sourceType;
@override@JsonKey() final  JobLanguage language;
@override@JsonKey() final  String text;
@override final  UploadFile? pickedFile;
@override@JsonKey() final  String sourceUrl;
@override@JsonKey() final  bool forceWhisper;
@override@JsonKey() final  bool idempotencyEnabled;
@override final  String? idempotencyKey;
@override@JsonKey() final  bool fileTooLarge;
@override@JsonKey() final  NewJobStatus status;
@override final  ApiError? lastError;
@override final  String? submittedJobId;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewJobStateCopyWith<_NewJobState> get copyWith => __$NewJobStateCopyWithImpl<_NewJobState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewJobState&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.text, text) || other.text == text)&&(identical(other.pickedFile, pickedFile) || other.pickedFile == pickedFile)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.idempotencyEnabled, idempotencyEnabled) || other.idempotencyEnabled == idempotencyEnabled)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.fileTooLarge, fileTooLarge) || other.fileTooLarge == fileTooLarge)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.submittedJobId, submittedJobId) || other.submittedJobId == submittedJobId));
}


@override
int get hashCode => Object.hash(runtimeType,sourceType,language,text,pickedFile,sourceUrl,forceWhisper,idempotencyEnabled,idempotencyKey,fileTooLarge,status,lastError,submittedJobId);

@override
String toString() {
  return 'NewJobState(sourceType: $sourceType, language: $language, text: $text, pickedFile: $pickedFile, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, idempotencyEnabled: $idempotencyEnabled, idempotencyKey: $idempotencyKey, fileTooLarge: $fileTooLarge, status: $status, lastError: $lastError, submittedJobId: $submittedJobId)';
}


}

/// @nodoc
abstract mixin class _$NewJobStateCopyWith<$Res> implements $NewJobStateCopyWith<$Res> {
  factory _$NewJobStateCopyWith(_NewJobState value, $Res Function(_NewJobState) _then) = __$NewJobStateCopyWithImpl;
@override @useResult
$Res call({
 NewJobSourceType sourceType, JobLanguage language, String text, UploadFile? pickedFile, String sourceUrl, bool forceWhisper, bool idempotencyEnabled, String? idempotencyKey, bool fileTooLarge, NewJobStatus status, ApiError? lastError, String? submittedJobId
});


@override $UploadFileCopyWith<$Res>? get pickedFile;@override $ApiErrorCopyWith<$Res>? get lastError;

}
/// @nodoc
class __$NewJobStateCopyWithImpl<$Res>
    implements _$NewJobStateCopyWith<$Res> {
  __$NewJobStateCopyWithImpl(this._self, this._then);

  final _NewJobState _self;
  final $Res Function(_NewJobState) _then;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceType = null,Object? language = null,Object? text = null,Object? pickedFile = freezed,Object? sourceUrl = null,Object? forceWhisper = null,Object? idempotencyEnabled = null,Object? idempotencyKey = freezed,Object? fileTooLarge = null,Object? status = null,Object? lastError = freezed,Object? submittedJobId = freezed,}) {
  return _then(_NewJobState(
sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as NewJobSourceType,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as JobLanguage,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,pickedFile: freezed == pickedFile ? _self.pickedFile : pickedFile // ignore: cast_nullable_to_non_nullable
as UploadFile?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,forceWhisper: null == forceWhisper ? _self.forceWhisper : forceWhisper // ignore: cast_nullable_to_non_nullable
as bool,idempotencyEnabled: null == idempotencyEnabled ? _self.idempotencyEnabled : idempotencyEnabled // ignore: cast_nullable_to_non_nullable
as bool,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,fileTooLarge: null == fileTooLarge ? _self.fileTooLarge : fileTooLarge // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NewJobStatus,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as ApiError?,submittedJobId: freezed == submittedJobId ? _self.submittedJobId : submittedJobId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadFileCopyWith<$Res>? get pickedFile {
    if (_self.pickedFile == null) {
    return null;
  }

  return $UploadFileCopyWith<$Res>(_self.pickedFile!, (value) {
    return _then(_self.copyWith(pickedFile: value));
  });
}/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<$Res>? get lastError {
    if (_self.lastError == null) {
    return null;
  }

  return $ApiErrorCopyWith<$Res>(_self.lastError!, (value) {
    return _then(_self.copyWith(lastError: value));
  });
}
}

// dart format on
