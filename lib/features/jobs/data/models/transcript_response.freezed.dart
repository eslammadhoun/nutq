// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranscriptResponse {

 String get language;@JsonKey(name: 'word_count') int? get wordCount;@JsonKey(name: 'duration_seconds') double? get durationSeconds;@JsonKey(name: 'model_name') String get modelName;@JsonKey(name: 'model_version') String get modelVersion; String? get quantization;@JsonKey(name: 'download_url') String? get downloadUrl;
/// Create a copy of TranscriptResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptResponseCopyWith<TranscriptResponse> get copyWith => _$TranscriptResponseCopyWithImpl<TranscriptResponse>(this as TranscriptResponse, _$identity);

  /// Serializes this TranscriptResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptResponse&&(identical(other.language, language) || other.language == language)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.quantization, quantization) || other.quantization == quantization)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,wordCount,durationSeconds,modelName,modelVersion,quantization,downloadUrl);

@override
String toString() {
  return 'TranscriptResponse(language: $language, wordCount: $wordCount, durationSeconds: $durationSeconds, modelName: $modelName, modelVersion: $modelVersion, quantization: $quantization, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class $TranscriptResponseCopyWith<$Res>  {
  factory $TranscriptResponseCopyWith(TranscriptResponse value, $Res Function(TranscriptResponse) _then) = _$TranscriptResponseCopyWithImpl;
@useResult
$Res call({
 String language,@JsonKey(name: 'word_count') int? wordCount,@JsonKey(name: 'duration_seconds') double? durationSeconds,@JsonKey(name: 'model_name') String modelName,@JsonKey(name: 'model_version') String modelVersion, String? quantization,@JsonKey(name: 'download_url') String? downloadUrl
});




}
/// @nodoc
class _$TranscriptResponseCopyWithImpl<$Res>
    implements $TranscriptResponseCopyWith<$Res> {
  _$TranscriptResponseCopyWithImpl(this._self, this._then);

  final TranscriptResponse _self;
  final $Res Function(TranscriptResponse) _then;

/// Create a copy of TranscriptResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? wordCount = freezed,Object? durationSeconds = freezed,Object? modelName = null,Object? modelVersion = null,Object? quantization = freezed,Object? downloadUrl = freezed,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,wordCount: freezed == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,quantization: freezed == quantization ? _self.quantization : quantization // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptResponse].
extension TranscriptResponsePatterns on TranscriptResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptResponse value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String language, @JsonKey(name: 'word_count')  int? wordCount, @JsonKey(name: 'duration_seconds')  double? durationSeconds, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'model_version')  String modelVersion,  String? quantization, @JsonKey(name: 'download_url')  String? downloadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptResponse() when $default != null:
return $default(_that.language,_that.wordCount,_that.durationSeconds,_that.modelName,_that.modelVersion,_that.quantization,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String language, @JsonKey(name: 'word_count')  int? wordCount, @JsonKey(name: 'duration_seconds')  double? durationSeconds, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'model_version')  String modelVersion,  String? quantization, @JsonKey(name: 'download_url')  String? downloadUrl)  $default,) {final _that = this;
switch (_that) {
case _TranscriptResponse():
return $default(_that.language,_that.wordCount,_that.durationSeconds,_that.modelName,_that.modelVersion,_that.quantization,_that.downloadUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String language, @JsonKey(name: 'word_count')  int? wordCount, @JsonKey(name: 'duration_seconds')  double? durationSeconds, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'model_version')  String modelVersion,  String? quantization, @JsonKey(name: 'download_url')  String? downloadUrl)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptResponse() when $default != null:
return $default(_that.language,_that.wordCount,_that.durationSeconds,_that.modelName,_that.modelVersion,_that.quantization,_that.downloadUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptResponse implements TranscriptResponse {
  const _TranscriptResponse({required this.language, @JsonKey(name: 'word_count') this.wordCount, @JsonKey(name: 'duration_seconds') this.durationSeconds, @JsonKey(name: 'model_name') required this.modelName, @JsonKey(name: 'model_version') required this.modelVersion, this.quantization, @JsonKey(name: 'download_url') this.downloadUrl});
  factory _TranscriptResponse.fromJson(Map<String, dynamic> json) => _$TranscriptResponseFromJson(json);

@override final  String language;
@override@JsonKey(name: 'word_count') final  int? wordCount;
@override@JsonKey(name: 'duration_seconds') final  double? durationSeconds;
@override@JsonKey(name: 'model_name') final  String modelName;
@override@JsonKey(name: 'model_version') final  String modelVersion;
@override final  String? quantization;
@override@JsonKey(name: 'download_url') final  String? downloadUrl;

/// Create a copy of TranscriptResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptResponseCopyWith<_TranscriptResponse> get copyWith => __$TranscriptResponseCopyWithImpl<_TranscriptResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptResponse&&(identical(other.language, language) || other.language == language)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.quantization, quantization) || other.quantization == quantization)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,wordCount,durationSeconds,modelName,modelVersion,quantization,downloadUrl);

@override
String toString() {
  return 'TranscriptResponse(language: $language, wordCount: $wordCount, durationSeconds: $durationSeconds, modelName: $modelName, modelVersion: $modelVersion, quantization: $quantization, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class _$TranscriptResponseCopyWith<$Res> implements $TranscriptResponseCopyWith<$Res> {
  factory _$TranscriptResponseCopyWith(_TranscriptResponse value, $Res Function(_TranscriptResponse) _then) = __$TranscriptResponseCopyWithImpl;
@override @useResult
$Res call({
 String language,@JsonKey(name: 'word_count') int? wordCount,@JsonKey(name: 'duration_seconds') double? durationSeconds,@JsonKey(name: 'model_name') String modelName,@JsonKey(name: 'model_version') String modelVersion, String? quantization,@JsonKey(name: 'download_url') String? downloadUrl
});




}
/// @nodoc
class __$TranscriptResponseCopyWithImpl<$Res>
    implements _$TranscriptResponseCopyWith<$Res> {
  __$TranscriptResponseCopyWithImpl(this._self, this._then);

  final _TranscriptResponse _self;
  final $Res Function(_TranscriptResponse) _then;

/// Create a copy of TranscriptResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? wordCount = freezed,Object? durationSeconds = freezed,Object? modelName = null,Object? modelVersion = null,Object? quantization = freezed,Object? downloadUrl = freezed,}) {
  return _then(_TranscriptResponse(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,wordCount: freezed == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double?,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,quantization: freezed == quantization ? _self.quantization : quantization // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
