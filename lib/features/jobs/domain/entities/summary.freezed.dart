// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Summary {

 String get summaryText; String get toneAndFormat; List<Map<String, dynamic>> get takeaways; String get modelName; String get promptVersion; int? get tokensIn; int? get tokensOut;
/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryCopyWith<Summary> get copyWith => _$SummaryCopyWithImpl<Summary>(this as Summary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Summary&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.toneAndFormat, toneAndFormat) || other.toneAndFormat == toneAndFormat)&&const DeepCollectionEquality().equals(other.takeaways, takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut));
}


@override
int get hashCode => Object.hash(runtimeType,summaryText,toneAndFormat,const DeepCollectionEquality().hash(takeaways),modelName,promptVersion,tokensIn,tokensOut);

@override
String toString() {
  return 'Summary(summaryText: $summaryText, toneAndFormat: $toneAndFormat, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, tokensIn: $tokensIn, tokensOut: $tokensOut)';
}


}

/// @nodoc
abstract mixin class $SummaryCopyWith<$Res>  {
  factory $SummaryCopyWith(Summary value, $Res Function(Summary) _then) = _$SummaryCopyWithImpl;
@useResult
$Res call({
 String summaryText, String toneAndFormat, List<Map<String, dynamic>> takeaways, String modelName, String promptVersion, int? tokensIn, int? tokensOut
});




}
/// @nodoc
class _$SummaryCopyWithImpl<$Res>
    implements $SummaryCopyWith<$Res> {
  _$SummaryCopyWithImpl(this._self, this._then);

  final Summary _self;
  final $Res Function(Summary) _then;

/// Create a copy of Summary
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


/// Adds pattern-matching-related methods to [Summary].
extension SummaryPatterns on Summary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Summary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Summary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Summary value)  $default,){
final _that = this;
switch (_that) {
case _Summary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Summary value)?  $default,){
final _that = this;
switch (_that) {
case _Summary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summaryText,  String toneAndFormat,  List<Map<String, dynamic>> takeaways,  String modelName,  String promptVersion,  int? tokensIn,  int? tokensOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summaryText,  String toneAndFormat,  List<Map<String, dynamic>> takeaways,  String modelName,  String promptVersion,  int? tokensIn,  int? tokensOut)  $default,) {final _that = this;
switch (_that) {
case _Summary():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summaryText,  String toneAndFormat,  List<Map<String, dynamic>> takeaways,  String modelName,  String promptVersion,  int? tokensIn,  int? tokensOut)?  $default,) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
return $default(_that.summaryText,_that.toneAndFormat,_that.takeaways,_that.modelName,_that.promptVersion,_that.tokensIn,_that.tokensOut);case _:
  return null;

}
}

}

/// @nodoc


class _Summary implements Summary {
  const _Summary({required this.summaryText, required this.toneAndFormat, required final  List<Map<String, dynamic>> takeaways, required this.modelName, required this.promptVersion, this.tokensIn, this.tokensOut}): _takeaways = takeaways;
  

@override final  String summaryText;
@override final  String toneAndFormat;
 final  List<Map<String, dynamic>> _takeaways;
@override List<Map<String, dynamic>> get takeaways {
  if (_takeaways is EqualUnmodifiableListView) return _takeaways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_takeaways);
}

@override final  String modelName;
@override final  String promptVersion;
@override final  int? tokensIn;
@override final  int? tokensOut;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryCopyWith<_Summary> get copyWith => __$SummaryCopyWithImpl<_Summary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Summary&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.toneAndFormat, toneAndFormat) || other.toneAndFormat == toneAndFormat)&&const DeepCollectionEquality().equals(other._takeaways, _takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut));
}


@override
int get hashCode => Object.hash(runtimeType,summaryText,toneAndFormat,const DeepCollectionEquality().hash(_takeaways),modelName,promptVersion,tokensIn,tokensOut);

@override
String toString() {
  return 'Summary(summaryText: $summaryText, toneAndFormat: $toneAndFormat, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, tokensIn: $tokensIn, tokensOut: $tokensOut)';
}


}

/// @nodoc
abstract mixin class _$SummaryCopyWith<$Res> implements $SummaryCopyWith<$Res> {
  factory _$SummaryCopyWith(_Summary value, $Res Function(_Summary) _then) = __$SummaryCopyWithImpl;
@override @useResult
$Res call({
 String summaryText, String toneAndFormat, List<Map<String, dynamic>> takeaways, String modelName, String promptVersion, int? tokensIn, int? tokensOut
});




}
/// @nodoc
class __$SummaryCopyWithImpl<$Res>
    implements _$SummaryCopyWith<$Res> {
  __$SummaryCopyWithImpl(this._self, this._then);

  final _Summary _self;
  final $Res Function(_Summary) _then;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summaryText = null,Object? toneAndFormat = null,Object? takeaways = null,Object? modelName = null,Object? promptVersion = null,Object? tokensIn = freezed,Object? tokensOut = freezed,}) {
  return _then(_Summary(
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
