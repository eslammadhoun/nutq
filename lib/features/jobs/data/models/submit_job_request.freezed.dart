// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_job_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitJobRequest {

@JsonKey(name: 'source_type') String get sourceType; String get language;@JsonKey(name: 'source_url') String? get sourceUrl;@JsonKey(name: 'force_whisper') bool get forceWhisper; String? get text; String? get filename;@JsonKey(name: 'content_type') String? get contentType;@JsonKey(name: 'size_hint') int? get sizeHint;@JsonKey(name: 'idempotency_key') String? get idempotencyKey;
/// Create a copy of SubmitJobRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitJobRequestCopyWith<SubmitJobRequest> get copyWith => _$SubmitJobRequestCopyWithImpl<SubmitJobRequest>(this as SubmitJobRequest, _$identity);

  /// Serializes this SubmitJobRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitJobRequest&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.text, text) || other.text == text)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeHint, sizeHint) || other.sizeHint == sizeHint)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceType,language,sourceUrl,forceWhisper,text,filename,contentType,sizeHint,idempotencyKey);

@override
String toString() {
  return 'SubmitJobRequest(sourceType: $sourceType, language: $language, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, text: $text, filename: $filename, contentType: $contentType, sizeHint: $sizeHint, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $SubmitJobRequestCopyWith<$Res>  {
  factory $SubmitJobRequestCopyWith(SubmitJobRequest value, $Res Function(SubmitJobRequest) _then) = _$SubmitJobRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'force_whisper') bool forceWhisper, String? text, String? filename,@JsonKey(name: 'content_type') String? contentType,@JsonKey(name: 'size_hint') int? sizeHint,@JsonKey(name: 'idempotency_key') String? idempotencyKey
});




}
/// @nodoc
class _$SubmitJobRequestCopyWithImpl<$Res>
    implements $SubmitJobRequestCopyWith<$Res> {
  _$SubmitJobRequestCopyWithImpl(this._self, this._then);

  final SubmitJobRequest _self;
  final $Res Function(SubmitJobRequest) _then;

/// Create a copy of SubmitJobRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceType = null,Object? language = null,Object? sourceUrl = freezed,Object? forceWhisper = null,Object? text = freezed,Object? filename = freezed,Object? contentType = freezed,Object? sizeHint = freezed,Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,forceWhisper: null == forceWhisper ? _self.forceWhisper : forceWhisper // ignore: cast_nullable_to_non_nullable
as bool,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeHint: freezed == sizeHint ? _self.sizeHint : sizeHint // ignore: cast_nullable_to_non_nullable
as int?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitJobRequest].
extension SubmitJobRequestPatterns on SubmitJobRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitJobRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitJobRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitJobRequest value)  $default,){
final _that = this;
switch (_that) {
case _SubmitJobRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitJobRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitJobRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'force_whisper')  bool forceWhisper,  String? text,  String? filename, @JsonKey(name: 'content_type')  String? contentType, @JsonKey(name: 'size_hint')  int? sizeHint, @JsonKey(name: 'idempotency_key')  String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitJobRequest() when $default != null:
return $default(_that.sourceType,_that.language,_that.sourceUrl,_that.forceWhisper,_that.text,_that.filename,_that.contentType,_that.sizeHint,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'force_whisper')  bool forceWhisper,  String? text,  String? filename, @JsonKey(name: 'content_type')  String? contentType, @JsonKey(name: 'size_hint')  int? sizeHint, @JsonKey(name: 'idempotency_key')  String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _SubmitJobRequest():
return $default(_that.sourceType,_that.language,_that.sourceUrl,_that.forceWhisper,_that.text,_that.filename,_that.contentType,_that.sizeHint,_that.idempotencyKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'source_type')  String sourceType,  String language, @JsonKey(name: 'source_url')  String? sourceUrl, @JsonKey(name: 'force_whisper')  bool forceWhisper,  String? text,  String? filename, @JsonKey(name: 'content_type')  String? contentType, @JsonKey(name: 'size_hint')  int? sizeHint, @JsonKey(name: 'idempotency_key')  String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _SubmitJobRequest() when $default != null:
return $default(_that.sourceType,_that.language,_that.sourceUrl,_that.forceWhisper,_that.text,_that.filename,_that.contentType,_that.sizeHint,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmitJobRequest implements SubmitJobRequest {
  const _SubmitJobRequest({@JsonKey(name: 'source_type') required this.sourceType, this.language = 'ar', @JsonKey(name: 'source_url') this.sourceUrl, @JsonKey(name: 'force_whisper') this.forceWhisper = false, this.text, this.filename, @JsonKey(name: 'content_type') this.contentType, @JsonKey(name: 'size_hint') this.sizeHint, @JsonKey(name: 'idempotency_key') this.idempotencyKey});
  factory _SubmitJobRequest.fromJson(Map<String, dynamic> json) => _$SubmitJobRequestFromJson(json);

@override@JsonKey(name: 'source_type') final  String sourceType;
@override@JsonKey() final  String language;
@override@JsonKey(name: 'source_url') final  String? sourceUrl;
@override@JsonKey(name: 'force_whisper') final  bool forceWhisper;
@override final  String? text;
@override final  String? filename;
@override@JsonKey(name: 'content_type') final  String? contentType;
@override@JsonKey(name: 'size_hint') final  int? sizeHint;
@override@JsonKey(name: 'idempotency_key') final  String? idempotencyKey;

/// Create a copy of SubmitJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitJobRequestCopyWith<_SubmitJobRequest> get copyWith => __$SubmitJobRequestCopyWithImpl<_SubmitJobRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitJobRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitJobRequest&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.text, text) || other.text == text)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeHint, sizeHint) || other.sizeHint == sizeHint)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceType,language,sourceUrl,forceWhisper,text,filename,contentType,sizeHint,idempotencyKey);

@override
String toString() {
  return 'SubmitJobRequest(sourceType: $sourceType, language: $language, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, text: $text, filename: $filename, contentType: $contentType, sizeHint: $sizeHint, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$SubmitJobRequestCopyWith<$Res> implements $SubmitJobRequestCopyWith<$Res> {
  factory _$SubmitJobRequestCopyWith(_SubmitJobRequest value, $Res Function(_SubmitJobRequest) _then) = __$SubmitJobRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'source_type') String sourceType, String language,@JsonKey(name: 'source_url') String? sourceUrl,@JsonKey(name: 'force_whisper') bool forceWhisper, String? text, String? filename,@JsonKey(name: 'content_type') String? contentType,@JsonKey(name: 'size_hint') int? sizeHint,@JsonKey(name: 'idempotency_key') String? idempotencyKey
});




}
/// @nodoc
class __$SubmitJobRequestCopyWithImpl<$Res>
    implements _$SubmitJobRequestCopyWith<$Res> {
  __$SubmitJobRequestCopyWithImpl(this._self, this._then);

  final _SubmitJobRequest _self;
  final $Res Function(_SubmitJobRequest) _then;

/// Create a copy of SubmitJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceType = null,Object? language = null,Object? sourceUrl = freezed,Object? forceWhisper = null,Object? text = freezed,Object? filename = freezed,Object? contentType = freezed,Object? sizeHint = freezed,Object? idempotencyKey = freezed,}) {
  return _then(_SubmitJobRequest(
sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,forceWhisper: null == forceWhisper ? _self.forceWhisper : forceWhisper // ignore: cast_nullable_to_non_nullable
as bool,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeHint: freezed == sizeHint ? _self.sizeHint : sizeHint // ignore: cast_nullable_to_non_nullable
as int?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
