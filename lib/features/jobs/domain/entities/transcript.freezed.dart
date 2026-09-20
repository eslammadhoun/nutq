// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transcript {

 String get text; int get wordCount;/// The speech-recognition model that produced the text; null for text the
/// user pasted.
 String? get modelName; String? get modelVersion;
/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptCopyWith<Transcript> get copyWith => _$TranscriptCopyWithImpl<Transcript>(this as Transcript, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transcript&&(identical(other.text, text) || other.text == text)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion));
}


@override
int get hashCode => Object.hash(runtimeType,text,wordCount,modelName,modelVersion);

@override
String toString() {
  return 'Transcript(text: $text, wordCount: $wordCount, modelName: $modelName, modelVersion: $modelVersion)';
}


}

/// @nodoc
abstract mixin class $TranscriptCopyWith<$Res>  {
  factory $TranscriptCopyWith(Transcript value, $Res Function(Transcript) _then) = _$TranscriptCopyWithImpl;
@useResult
$Res call({
 String text, int wordCount, String? modelName, String? modelVersion
});




}
/// @nodoc
class _$TranscriptCopyWithImpl<$Res>
    implements $TranscriptCopyWith<$Res> {
  _$TranscriptCopyWithImpl(this._self, this._then);

  final Transcript _self;
  final $Res Function(Transcript) _then;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? wordCount = null,Object? modelName = freezed,Object? modelVersion = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,modelVersion: freezed == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Transcript].
extension TranscriptPatterns on Transcript {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transcript value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transcript() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transcript value)  $default,){
final _that = this;
switch (_that) {
case _Transcript():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transcript value)?  $default,){
final _that = this;
switch (_that) {
case _Transcript() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int wordCount,  String? modelName,  String? modelVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that.text,_that.wordCount,_that.modelName,_that.modelVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int wordCount,  String? modelName,  String? modelVersion)  $default,) {final _that = this;
switch (_that) {
case _Transcript():
return $default(_that.text,_that.wordCount,_that.modelName,_that.modelVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int wordCount,  String? modelName,  String? modelVersion)?  $default,) {final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that.text,_that.wordCount,_that.modelName,_that.modelVersion);case _:
  return null;

}
}

}

/// @nodoc


class _Transcript implements Transcript {
  const _Transcript({required this.text, required this.wordCount, this.modelName, this.modelVersion});
  

@override final  String text;
@override final  int wordCount;
/// The speech-recognition model that produced the text; null for text the
/// user pasted.
@override final  String? modelName;
@override final  String? modelVersion;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptCopyWith<_Transcript> get copyWith => __$TranscriptCopyWithImpl<_Transcript>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transcript&&(identical(other.text, text) || other.text == text)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion));
}


@override
int get hashCode => Object.hash(runtimeType,text,wordCount,modelName,modelVersion);

@override
String toString() {
  return 'Transcript(text: $text, wordCount: $wordCount, modelName: $modelName, modelVersion: $modelVersion)';
}


}

/// @nodoc
abstract mixin class _$TranscriptCopyWith<$Res> implements $TranscriptCopyWith<$Res> {
  factory _$TranscriptCopyWith(_Transcript value, $Res Function(_Transcript) _then) = __$TranscriptCopyWithImpl;
@override @useResult
$Res call({
 String text, int wordCount, String? modelName, String? modelVersion
});




}
/// @nodoc
class __$TranscriptCopyWithImpl<$Res>
    implements _$TranscriptCopyWith<$Res> {
  __$TranscriptCopyWithImpl(this._self, this._then);

  final _Transcript _self;
  final $Res Function(_Transcript) _then;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? wordCount = null,Object? modelName = freezed,Object? modelVersion = freezed,}) {
  return _then(_Transcript(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,modelVersion: freezed == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
