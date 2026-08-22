// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SummaryResponse {

@JsonKey(name: 'summary_text') String get summaryText;@JsonKey(name: 'tone_and_format') String get toneAndFormat; List<Map<String, dynamic>> get takeaways;@JsonKey(name: 'model_name') String get modelName;@JsonKey(name: 'prompt_version') String get promptVersion;@JsonKey(name: 'tokens_in') int? get tokensIn;@JsonKey(name: 'tokens_out') int? get tokensOut;
/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryResponseCopyWith<SummaryResponse> get copyWith => _$SummaryResponseCopyWithImpl<SummaryResponse>(this as SummaryResponse, _$identity);

  /// Serializes this SummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryResponse&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.toneAndFormat, toneAndFormat) || other.toneAndFormat == toneAndFormat)&&const DeepCollectionEquality().equals(other.takeaways, takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summaryText,toneAndFormat,const DeepCollectionEquality().hash(takeaways),modelName,promptVersion,tokensIn,tokensOut);

@override
String toString() {
  return 'SummaryResponse(summaryText: $summaryText, toneAndFormat: $toneAndFormat, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, tokensIn: $tokensIn, tokensOut: $tokensOut)';
}


}

/// @nodoc
abstract mixin class $SummaryResponseCopyWith<$Res>  {
  factory $SummaryResponseCopyWith(SummaryResponse value, $Res Function(SummaryResponse) _then) = _$SummaryResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'summary_text') String summaryText,@JsonKey(name: 'tone_and_format') String toneAndFormat, List<Map<String, dynamic>> takeaways,@JsonKey(name: 'model_name') String modelName,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'tokens_in') int? tokensIn,@JsonKey(name: 'tokens_out') int? tokensOut
});




}
/// @nodoc
class _$SummaryResponseCopyWithImpl<$Res>
    implements $SummaryResponseCopyWith<$Res> {
  _$SummaryResponseCopyWithImpl(this._self, this._then);

  final SummaryResponse _self;
  final $Res Function(SummaryResponse) _then;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summaryText = null,Object? toneAndFormat = null,Object? takeaways = null,Object? modelName = null,Object? promptVersion = null,Object? tokensIn = freezed,Object? tokensOut = freezed,}) {
  return _then(_self.copyWith(
summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,toneAndFormat: null == toneAndFormat ? _self.toneAndFormat : toneAndFormat // ignore: cast_nullable_to_non_nullable
as String,takeaways: null == takeaways ? _self.takeaways : takeaways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,tokensIn: freezed == tokensIn ? _self.tokensIn : tokensIn // ignore: cast_nullable_to_non_nullable
as int?,tokensOut: freezed == tokensOut ? _self.tokensOut : tokensOut // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryResponse].
extension SummaryResponsePatterns on SummaryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryResponse value)  $default,){
final _that = this;
switch (_that) {
case _SummaryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'summary_text')  String summaryText, @JsonKey(name: 'tone_and_format')  String toneAndFormat,  List<Map<String, dynamic>> takeaways, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'tokens_in')  int? tokensIn, @JsonKey(name: 'tokens_out')  int? tokensOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
return $default(_that.summaryText,_that.toneAndFormat,_that.takeaways,_that.modelName,_that.promptVersion,_that.tokensIn,_that.tokensOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'summary_text')  String summaryText, @JsonKey(name: 'tone_and_format')  String toneAndFormat,  List<Map<String, dynamic>> takeaways, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'tokens_in')  int? tokensIn, @JsonKey(name: 'tokens_out')  int? tokensOut)  $default,) {final _that = this;
switch (_that) {
case _SummaryResponse():
return $default(_that.summaryText,_that.toneAndFormat,_that.takeaways,_that.modelName,_that.promptVersion,_that.tokensIn,_that.tokensOut);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'summary_text')  String summaryText, @JsonKey(name: 'tone_and_format')  String toneAndFormat,  List<Map<String, dynamic>> takeaways, @JsonKey(name: 'model_name')  String modelName, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'tokens_in')  int? tokensIn, @JsonKey(name: 'tokens_out')  int? tokensOut)?  $default,) {final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
return $default(_that.summaryText,_that.toneAndFormat,_that.takeaways,_that.modelName,_that.promptVersion,_that.tokensIn,_that.tokensOut);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryResponse implements SummaryResponse {
  const _SummaryResponse({@JsonKey(name: 'summary_text') required this.summaryText, @JsonKey(name: 'tone_and_format') required this.toneAndFormat, required final  List<Map<String, dynamic>> takeaways, @JsonKey(name: 'model_name') required this.modelName, @JsonKey(name: 'prompt_version') required this.promptVersion, @JsonKey(name: 'tokens_in') this.tokensIn, @JsonKey(name: 'tokens_out') this.tokensOut}): _takeaways = takeaways;
  factory _SummaryResponse.fromJson(Map<String, dynamic> json) => _$SummaryResponseFromJson(json);

@override@JsonKey(name: 'summary_text') final  String summaryText;
@override@JsonKey(name: 'tone_and_format') final  String toneAndFormat;
 final  List<Map<String, dynamic>> _takeaways;
@override List<Map<String, dynamic>> get takeaways {
  if (_takeaways is EqualUnmodifiableListView) return _takeaways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_takeaways);
}

@override@JsonKey(name: 'model_name') final  String modelName;
@override@JsonKey(name: 'prompt_version') final  String promptVersion;
@override@JsonKey(name: 'tokens_in') final  int? tokensIn;
@override@JsonKey(name: 'tokens_out') final  int? tokensOut;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryResponseCopyWith<_SummaryResponse> get copyWith => __$SummaryResponseCopyWithImpl<_SummaryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryResponse&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.toneAndFormat, toneAndFormat) || other.toneAndFormat == toneAndFormat)&&const DeepCollectionEquality().equals(other._takeaways, _takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summaryText,toneAndFormat,const DeepCollectionEquality().hash(_takeaways),modelName,promptVersion,tokensIn,tokensOut);

@override
String toString() {
  return 'SummaryResponse(summaryText: $summaryText, toneAndFormat: $toneAndFormat, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, tokensIn: $tokensIn, tokensOut: $tokensOut)';
}


}

/// @nodoc
abstract mixin class _$SummaryResponseCopyWith<$Res> implements $SummaryResponseCopyWith<$Res> {
  factory _$SummaryResponseCopyWith(_SummaryResponse value, $Res Function(_SummaryResponse) _then) = __$SummaryResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'summary_text') String summaryText,@JsonKey(name: 'tone_and_format') String toneAndFormat, List<Map<String, dynamic>> takeaways,@JsonKey(name: 'model_name') String modelName,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'tokens_in') int? tokensIn,@JsonKey(name: 'tokens_out') int? tokensOut
});




}
/// @nodoc
class __$SummaryResponseCopyWithImpl<$Res>
    implements _$SummaryResponseCopyWith<$Res> {
  __$SummaryResponseCopyWithImpl(this._self, this._then);

  final _SummaryResponse _self;
  final $Res Function(_SummaryResponse) _then;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summaryText = null,Object? toneAndFormat = null,Object? takeaways = null,Object? modelName = null,Object? promptVersion = null,Object? tokensIn = freezed,Object? tokensOut = freezed,}) {
  return _then(_SummaryResponse(
summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,toneAndFormat: null == toneAndFormat ? _self.toneAndFormat : toneAndFormat // ignore: cast_nullable_to_non_nullable
as String,takeaways: null == takeaways ? _self._takeaways : takeaways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,tokensIn: freezed == tokensIn ? _self.tokensIn : tokensIn // ignore: cast_nullable_to_non_nullable
as int?,tokensOut: freezed == tokensOut ? _self.tokensOut : tokensOut // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
