// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_job_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubmitJobParams {

 String get sourceType; String get language; String? get sourceUrl; bool get forceWhisper; String? get text; String? get filename; String? get contentType; int? get sizeHint; String? get idempotencyKey;
/// Create a copy of SubmitJobParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitJobParamsCopyWith<SubmitJobParams> get copyWith => _$SubmitJobParamsCopyWithImpl<SubmitJobParams>(this as SubmitJobParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitJobParams&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.text, text) || other.text == text)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeHint, sizeHint) || other.sizeHint == sizeHint)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,sourceType,language,sourceUrl,forceWhisper,text,filename,contentType,sizeHint,idempotencyKey);

@override
String toString() {
  return 'SubmitJobParams(sourceType: $sourceType, language: $language, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, text: $text, filename: $filename, contentType: $contentType, sizeHint: $sizeHint, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $SubmitJobParamsCopyWith<$Res>  {
  factory $SubmitJobParamsCopyWith(SubmitJobParams value, $Res Function(SubmitJobParams) _then) = _$SubmitJobParamsCopyWithImpl;
@useResult
$Res call({
 String sourceType, String language, String? sourceUrl, bool forceWhisper, String? text, String? filename, String? contentType, int? sizeHint, String? idempotencyKey
});




}
/// @nodoc
class _$SubmitJobParamsCopyWithImpl<$Res>
    implements $SubmitJobParamsCopyWith<$Res> {
  _$SubmitJobParamsCopyWithImpl(this._self, this._then);

  final SubmitJobParams _self;
  final $Res Function(SubmitJobParams) _then;

/// Create a copy of SubmitJobParams
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


/// Adds pattern-matching-related methods to [SubmitJobParams].
extension SubmitJobParamsPatterns on SubmitJobParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitJobParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitJobParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitJobParams value)  $default,){
final _that = this;
switch (_that) {
case _SubmitJobParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitJobParams value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitJobParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceType,  String language,  String? sourceUrl,  bool forceWhisper,  String? text,  String? filename,  String? contentType,  int? sizeHint,  String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitJobParams() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceType,  String language,  String? sourceUrl,  bool forceWhisper,  String? text,  String? filename,  String? contentType,  int? sizeHint,  String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _SubmitJobParams():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceType,  String language,  String? sourceUrl,  bool forceWhisper,  String? text,  String? filename,  String? contentType,  int? sizeHint,  String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _SubmitJobParams() when $default != null:
return $default(_that.sourceType,_that.language,_that.sourceUrl,_that.forceWhisper,_that.text,_that.filename,_that.contentType,_that.sizeHint,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _SubmitJobParams implements SubmitJobParams {
  const _SubmitJobParams({required this.sourceType, this.language = 'ar', this.sourceUrl, this.forceWhisper = false, this.text, this.filename, this.contentType, this.sizeHint, this.idempotencyKey});
  

@override final  String sourceType;
@override@JsonKey() final  String language;
@override final  String? sourceUrl;
@override@JsonKey() final  bool forceWhisper;
@override final  String? text;
@override final  String? filename;
@override final  String? contentType;
@override final  int? sizeHint;
@override final  String? idempotencyKey;

/// Create a copy of SubmitJobParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitJobParamsCopyWith<_SubmitJobParams> get copyWith => __$SubmitJobParamsCopyWithImpl<_SubmitJobParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitJobParams&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.forceWhisper, forceWhisper) || other.forceWhisper == forceWhisper)&&(identical(other.text, text) || other.text == text)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeHint, sizeHint) || other.sizeHint == sizeHint)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,sourceType,language,sourceUrl,forceWhisper,text,filename,contentType,sizeHint,idempotencyKey);

@override
String toString() {
  return 'SubmitJobParams(sourceType: $sourceType, language: $language, sourceUrl: $sourceUrl, forceWhisper: $forceWhisper, text: $text, filename: $filename, contentType: $contentType, sizeHint: $sizeHint, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$SubmitJobParamsCopyWith<$Res> implements $SubmitJobParamsCopyWith<$Res> {
  factory _$SubmitJobParamsCopyWith(_SubmitJobParams value, $Res Function(_SubmitJobParams) _then) = __$SubmitJobParamsCopyWithImpl;
@override @useResult
$Res call({
 String sourceType, String language, String? sourceUrl, bool forceWhisper, String? text, String? filename, String? contentType, int? sizeHint, String? idempotencyKey
});




}
/// @nodoc
class __$SubmitJobParamsCopyWithImpl<$Res>
    implements _$SubmitJobParamsCopyWith<$Res> {
  __$SubmitJobParamsCopyWithImpl(this._self, this._then);

  final _SubmitJobParams _self;
  final $Res Function(_SubmitJobParams) _then;

/// Create a copy of SubmitJobParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceType = null,Object? language = null,Object? sourceUrl = freezed,Object? forceWhisper = null,Object? text = freezed,Object? filename = freezed,Object? contentType = freezed,Object? sizeHint = freezed,Object? idempotencyKey = freezed,}) {
  return _then(_SubmitJobParams(
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
