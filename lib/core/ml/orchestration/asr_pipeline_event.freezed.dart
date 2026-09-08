// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asr_pipeline_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AsrPipelineEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsrPipelineEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsrPipelineEvent()';
}


}

/// @nodoc
class $AsrPipelineEventCopyWith<$Res>  {
$AsrPipelineEventCopyWith(AsrPipelineEvent _, $Res Function(AsrPipelineEvent) __);
}


/// Adds pattern-matching-related methods to [AsrPipelineEvent].
extension AsrPipelineEventPatterns on AsrPipelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AsrPipelineProgress value)?  progress,TResult Function( AsrPipelineTranscriptBatch value)?  transcriptBatch,TResult Function( AsrPipelineDone value)?  done,TResult Function( AsrPipelineError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AsrPipelineProgress() when progress != null:
return progress(_that);case AsrPipelineTranscriptBatch() when transcriptBatch != null:
return transcriptBatch(_that);case AsrPipelineDone() when done != null:
return done(_that);case AsrPipelineError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AsrPipelineProgress value)  progress,required TResult Function( AsrPipelineTranscriptBatch value)  transcriptBatch,required TResult Function( AsrPipelineDone value)  done,required TResult Function( AsrPipelineError value)  error,}){
final _that = this;
switch (_that) {
case AsrPipelineProgress():
return progress(_that);case AsrPipelineTranscriptBatch():
return transcriptBatch(_that);case AsrPipelineDone():
return done(_that);case AsrPipelineError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AsrPipelineProgress value)?  progress,TResult? Function( AsrPipelineTranscriptBatch value)?  transcriptBatch,TResult? Function( AsrPipelineDone value)?  done,TResult? Function( AsrPipelineError value)?  error,}){
final _that = this;
switch (_that) {
case AsrPipelineProgress() when progress != null:
return progress(_that);case AsrPipelineTranscriptBatch() when transcriptBatch != null:
return transcriptBatch(_that);case AsrPipelineDone() when done != null:
return done(_that);case AsrPipelineError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int chunkIndex,  int chunkTotal,  int percent)?  progress,TResult Function( String text)?  transcriptBatch,TResult Function( String fullText,  int wordCount,  Duration duration)?  done,TResult Function( ApiError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AsrPipelineProgress() when progress != null:
return progress(_that.chunkIndex,_that.chunkTotal,_that.percent);case AsrPipelineTranscriptBatch() when transcriptBatch != null:
return transcriptBatch(_that.text);case AsrPipelineDone() when done != null:
return done(_that.fullText,_that.wordCount,_that.duration);case AsrPipelineError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int chunkIndex,  int chunkTotal,  int percent)  progress,required TResult Function( String text)  transcriptBatch,required TResult Function( String fullText,  int wordCount,  Duration duration)  done,required TResult Function( ApiError error)  error,}) {final _that = this;
switch (_that) {
case AsrPipelineProgress():
return progress(_that.chunkIndex,_that.chunkTotal,_that.percent);case AsrPipelineTranscriptBatch():
return transcriptBatch(_that.text);case AsrPipelineDone():
return done(_that.fullText,_that.wordCount,_that.duration);case AsrPipelineError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int chunkIndex,  int chunkTotal,  int percent)?  progress,TResult? Function( String text)?  transcriptBatch,TResult? Function( String fullText,  int wordCount,  Duration duration)?  done,TResult? Function( ApiError error)?  error,}) {final _that = this;
switch (_that) {
case AsrPipelineProgress() when progress != null:
return progress(_that.chunkIndex,_that.chunkTotal,_that.percent);case AsrPipelineTranscriptBatch() when transcriptBatch != null:
return transcriptBatch(_that.text);case AsrPipelineDone() when done != null:
return done(_that.fullText,_that.wordCount,_that.duration);case AsrPipelineError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AsrPipelineProgress implements AsrPipelineEvent {
  const AsrPipelineProgress({required this.chunkIndex, required this.chunkTotal, required this.percent});
  

 final  int chunkIndex;
 final  int chunkTotal;
 final  int percent;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsrPipelineProgressCopyWith<AsrPipelineProgress> get copyWith => _$AsrPipelineProgressCopyWithImpl<AsrPipelineProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsrPipelineProgress&&(identical(other.chunkIndex, chunkIndex) || other.chunkIndex == chunkIndex)&&(identical(other.chunkTotal, chunkTotal) || other.chunkTotal == chunkTotal)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,chunkIndex,chunkTotal,percent);

@override
String toString() {
  return 'AsrPipelineEvent.progress(chunkIndex: $chunkIndex, chunkTotal: $chunkTotal, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $AsrPipelineProgressCopyWith<$Res> implements $AsrPipelineEventCopyWith<$Res> {
  factory $AsrPipelineProgressCopyWith(AsrPipelineProgress value, $Res Function(AsrPipelineProgress) _then) = _$AsrPipelineProgressCopyWithImpl;
@useResult
$Res call({
 int chunkIndex, int chunkTotal, int percent
});




}
/// @nodoc
class _$AsrPipelineProgressCopyWithImpl<$Res>
    implements $AsrPipelineProgressCopyWith<$Res> {
  _$AsrPipelineProgressCopyWithImpl(this._self, this._then);

  final AsrPipelineProgress _self;
  final $Res Function(AsrPipelineProgress) _then;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chunkIndex = null,Object? chunkTotal = null,Object? percent = null,}) {
  return _then(AsrPipelineProgress(
chunkIndex: null == chunkIndex ? _self.chunkIndex : chunkIndex // ignore: cast_nullable_to_non_nullable
as int,chunkTotal: null == chunkTotal ? _self.chunkTotal : chunkTotal // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class AsrPipelineTranscriptBatch implements AsrPipelineEvent {
  const AsrPipelineTranscriptBatch({required this.text});
  

 final  String text;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsrPipelineTranscriptBatchCopyWith<AsrPipelineTranscriptBatch> get copyWith => _$AsrPipelineTranscriptBatchCopyWithImpl<AsrPipelineTranscriptBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsrPipelineTranscriptBatch&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'AsrPipelineEvent.transcriptBatch(text: $text)';
}


}

/// @nodoc
abstract mixin class $AsrPipelineTranscriptBatchCopyWith<$Res> implements $AsrPipelineEventCopyWith<$Res> {
  factory $AsrPipelineTranscriptBatchCopyWith(AsrPipelineTranscriptBatch value, $Res Function(AsrPipelineTranscriptBatch) _then) = _$AsrPipelineTranscriptBatchCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$AsrPipelineTranscriptBatchCopyWithImpl<$Res>
    implements $AsrPipelineTranscriptBatchCopyWith<$Res> {
  _$AsrPipelineTranscriptBatchCopyWithImpl(this._self, this._then);

  final AsrPipelineTranscriptBatch _self;
  final $Res Function(AsrPipelineTranscriptBatch) _then;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(AsrPipelineTranscriptBatch(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AsrPipelineDone implements AsrPipelineEvent {
  const AsrPipelineDone({required this.fullText, required this.wordCount, required this.duration});
  

 final  String fullText;
 final  int wordCount;
 final  Duration duration;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsrPipelineDoneCopyWith<AsrPipelineDone> get copyWith => _$AsrPipelineDoneCopyWithImpl<AsrPipelineDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsrPipelineDone&&(identical(other.fullText, fullText) || other.fullText == fullText)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode => Object.hash(runtimeType,fullText,wordCount,duration);

@override
String toString() {
  return 'AsrPipelineEvent.done(fullText: $fullText, wordCount: $wordCount, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $AsrPipelineDoneCopyWith<$Res> implements $AsrPipelineEventCopyWith<$Res> {
  factory $AsrPipelineDoneCopyWith(AsrPipelineDone value, $Res Function(AsrPipelineDone) _then) = _$AsrPipelineDoneCopyWithImpl;
@useResult
$Res call({
 String fullText, int wordCount, Duration duration
});




}
/// @nodoc
class _$AsrPipelineDoneCopyWithImpl<$Res>
    implements $AsrPipelineDoneCopyWith<$Res> {
  _$AsrPipelineDoneCopyWithImpl(this._self, this._then);

  final AsrPipelineDone _self;
  final $Res Function(AsrPipelineDone) _then;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fullText = null,Object? wordCount = null,Object? duration = null,}) {
  return _then(AsrPipelineDone(
fullText: null == fullText ? _self.fullText : fullText // ignore: cast_nullable_to_non_nullable
as String,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class AsrPipelineError implements AsrPipelineEvent {
  const AsrPipelineError({required this.error});
  

 final  ApiError error;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsrPipelineErrorCopyWith<AsrPipelineError> get copyWith => _$AsrPipelineErrorCopyWithImpl<AsrPipelineError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsrPipelineError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'AsrPipelineEvent.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $AsrPipelineErrorCopyWith<$Res> implements $AsrPipelineEventCopyWith<$Res> {
  factory $AsrPipelineErrorCopyWith(AsrPipelineError value, $Res Function(AsrPipelineError) _then) = _$AsrPipelineErrorCopyWithImpl;
@useResult
$Res call({
 ApiError error
});


$ApiErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$AsrPipelineErrorCopyWithImpl<$Res>
    implements $AsrPipelineErrorCopyWith<$Res> {
  _$AsrPipelineErrorCopyWithImpl(this._self, this._then);

  final AsrPipelineError _self;
  final $Res Function(AsrPipelineError) _then;

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AsrPipelineError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiError,
  ));
}

/// Create a copy of AsrPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<$Res> get error {
  
  return $ApiErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
