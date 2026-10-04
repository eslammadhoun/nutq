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

 String get summaryText; SummaryLength get length; List<String> get takeaways; String get modelName; String get promptVersion;/// True when the heuristic checks could not match some detail of the
/// summary to the transcript.
 bool get needsReview; int? get tokensIn; int? get tokensOut; int? get processingTimeMs;
/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryCopyWith<Summary> get copyWith => _$SummaryCopyWithImpl<Summary>(this as Summary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Summary&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.length, length) || other.length == length)&&const DeepCollectionEquality().equals(other.takeaways, takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.needsReview, needsReview) || other.needsReview == needsReview)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut)&&(identical(other.processingTimeMs, processingTimeMs) || other.processingTimeMs == processingTimeMs));
}


@override
int get hashCode => Object.hash(runtimeType,summaryText,length,const DeepCollectionEquality().hash(takeaways),modelName,promptVersion,needsReview,tokensIn,tokensOut,processingTimeMs);

@override
String toString() {
  return 'Summary(summaryText: $summaryText, length: $length, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, needsReview: $needsReview, tokensIn: $tokensIn, tokensOut: $tokensOut, processingTimeMs: $processingTimeMs)';
}


}

/// @nodoc
abstract mixin class $SummaryCopyWith<$Res>  {
  factory $SummaryCopyWith(Summary value, $Res Function(Summary) _then) = _$SummaryCopyWithImpl;
@useResult
$Res call({
 String summaryText, SummaryLength length, List<String> takeaways, String modelName, String promptVersion, bool needsReview, int? tokensIn, int? tokensOut, int? processingTimeMs
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
@pragma('vm:prefer-inline') @override $Res call({Object? summaryText = null,Object? length = null,Object? takeaways = null,Object? modelName = null,Object? promptVersion = null,Object? needsReview = null,Object? tokensIn = freezed,Object? tokensOut = freezed,Object? processingTimeMs = freezed,}) {
  return _then(_self.copyWith(
summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as SummaryLength,takeaways: null == takeaways ? _self.takeaways : takeaways // ignore: cast_nullable_to_non_nullable
as List<String>,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,needsReview: null == needsReview ? _self.needsReview : needsReview // ignore: cast_nullable_to_non_nullable
as bool,tokensIn: freezed == tokensIn ? _self.tokensIn : tokensIn // ignore: cast_nullable_to_non_nullable
as int?,tokensOut: freezed == tokensOut ? _self.tokensOut : tokensOut // ignore: cast_nullable_to_non_nullable
as int?,processingTimeMs: freezed == processingTimeMs ? _self.processingTimeMs : processingTimeMs // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summaryText,  SummaryLength length,  List<String> takeaways,  String modelName,  String promptVersion,  bool needsReview,  int? tokensIn,  int? tokensOut,  int? processingTimeMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
return $default(_that.summaryText,_that.length,_that.takeaways,_that.modelName,_that.promptVersion,_that.needsReview,_that.tokensIn,_that.tokensOut,_that.processingTimeMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summaryText,  SummaryLength length,  List<String> takeaways,  String modelName,  String promptVersion,  bool needsReview,  int? tokensIn,  int? tokensOut,  int? processingTimeMs)  $default,) {final _that = this;
switch (_that) {
case _Summary():
return $default(_that.summaryText,_that.length,_that.takeaways,_that.modelName,_that.promptVersion,_that.needsReview,_that.tokensIn,_that.tokensOut,_that.processingTimeMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summaryText,  SummaryLength length,  List<String> takeaways,  String modelName,  String promptVersion,  bool needsReview,  int? tokensIn,  int? tokensOut,  int? processingTimeMs)?  $default,) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
return $default(_that.summaryText,_that.length,_that.takeaways,_that.modelName,_that.promptVersion,_that.needsReview,_that.tokensIn,_that.tokensOut,_that.processingTimeMs);case _:
  return null;

}
}

}

/// @nodoc


class _Summary implements Summary {
  const _Summary({required this.summaryText, required this.length, required final  List<String> takeaways, required this.modelName, required this.promptVersion, this.needsReview = false, this.tokensIn, this.tokensOut, this.processingTimeMs}): _takeaways = takeaways;
  

@override final  String summaryText;
@override final  SummaryLength length;
 final  List<String> _takeaways;
@override List<String> get takeaways {
  if (_takeaways is EqualUnmodifiableListView) return _takeaways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_takeaways);
}

@override final  String modelName;
@override final  String promptVersion;
/// True when the heuristic checks could not match some detail of the
/// summary to the transcript.
@override@JsonKey() final  bool needsReview;
@override final  int? tokensIn;
@override final  int? tokensOut;
@override final  int? processingTimeMs;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryCopyWith<_Summary> get copyWith => __$SummaryCopyWithImpl<_Summary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Summary&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.length, length) || other.length == length)&&const DeepCollectionEquality().equals(other._takeaways, _takeaways)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.needsReview, needsReview) || other.needsReview == needsReview)&&(identical(other.tokensIn, tokensIn) || other.tokensIn == tokensIn)&&(identical(other.tokensOut, tokensOut) || other.tokensOut == tokensOut)&&(identical(other.processingTimeMs, processingTimeMs) || other.processingTimeMs == processingTimeMs));
}


@override
int get hashCode => Object.hash(runtimeType,summaryText,length,const DeepCollectionEquality().hash(_takeaways),modelName,promptVersion,needsReview,tokensIn,tokensOut,processingTimeMs);

@override
String toString() {
  return 'Summary(summaryText: $summaryText, length: $length, takeaways: $takeaways, modelName: $modelName, promptVersion: $promptVersion, needsReview: $needsReview, tokensIn: $tokensIn, tokensOut: $tokensOut, processingTimeMs: $processingTimeMs)';
}


}

/// @nodoc
abstract mixin class _$SummaryCopyWith<$Res> implements $SummaryCopyWith<$Res> {
  factory _$SummaryCopyWith(_Summary value, $Res Function(_Summary) _then) = __$SummaryCopyWithImpl;
@override @useResult
$Res call({
 String summaryText, SummaryLength length, List<String> takeaways, String modelName, String promptVersion, bool needsReview, int? tokensIn, int? tokensOut, int? processingTimeMs
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
@override @pragma('vm:prefer-inline') $Res call({Object? summaryText = null,Object? length = null,Object? takeaways = null,Object? modelName = null,Object? promptVersion = null,Object? needsReview = null,Object? tokensIn = freezed,Object? tokensOut = freezed,Object? processingTimeMs = freezed,}) {
  return _then(_Summary(
summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as SummaryLength,takeaways: null == takeaways ? _self._takeaways : takeaways // ignore: cast_nullable_to_non_nullable
as List<String>,modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,needsReview: null == needsReview ? _self.needsReview : needsReview // ignore: cast_nullable_to_non_nullable
as bool,tokensIn: freezed == tokensIn ? _self.tokensIn : tokensIn // ignore: cast_nullable_to_non_nullable
as int?,tokensOut: freezed == tokensOut ? _self.tokensOut : tokensOut // ignore: cast_nullable_to_non_nullable
as int?,processingTimeMs: freezed == processingTimeMs ? _self.processingTimeMs : processingTimeMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
