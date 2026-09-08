// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whisper_engine_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WhisperEngineEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhisperEngineEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WhisperEngineEvent()';
}


}

/// @nodoc
class $WhisperEngineEventCopyWith<$Res>  {
$WhisperEngineEventCopyWith(WhisperEngineEvent _, $Res Function(WhisperEngineEvent) __);
}


/// Adds pattern-matching-related methods to [WhisperEngineEvent].
extension WhisperEngineEventPatterns on WhisperEngineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WhisperEngineProgress value)?  progress,TResult Function( WhisperEngineSegment value)?  segment,TResult Function( WhisperEngineDone value)?  done,TResult Function( WhisperEngineError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WhisperEngineProgress() when progress != null:
return progress(_that);case WhisperEngineSegment() when segment != null:
return segment(_that);case WhisperEngineDone() when done != null:
return done(_that);case WhisperEngineError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WhisperEngineProgress value)  progress,required TResult Function( WhisperEngineSegment value)  segment,required TResult Function( WhisperEngineDone value)  done,required TResult Function( WhisperEngineError value)  error,}){
final _that = this;
switch (_that) {
case WhisperEngineProgress():
return progress(_that);case WhisperEngineSegment():
return segment(_that);case WhisperEngineDone():
return done(_that);case WhisperEngineError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WhisperEngineProgress value)?  progress,TResult? Function( WhisperEngineSegment value)?  segment,TResult? Function( WhisperEngineDone value)?  done,TResult? Function( WhisperEngineError value)?  error,}){
final _that = this;
switch (_that) {
case WhisperEngineProgress() when progress != null:
return progress(_that);case WhisperEngineSegment() when segment != null:
return segment(_that);case WhisperEngineDone() when done != null:
return done(_that);case WhisperEngineError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int percent)?  progress,TResult Function( String text,  Duration start,  Duration end)?  segment,TResult Function( String fullText)?  done,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WhisperEngineProgress() when progress != null:
return progress(_that.percent);case WhisperEngineSegment() when segment != null:
return segment(_that.text,_that.start,_that.end);case WhisperEngineDone() when done != null:
return done(_that.fullText);case WhisperEngineError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int percent)  progress,required TResult Function( String text,  Duration start,  Duration end)  segment,required TResult Function( String fullText)  done,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case WhisperEngineProgress():
return progress(_that.percent);case WhisperEngineSegment():
return segment(_that.text,_that.start,_that.end);case WhisperEngineDone():
return done(_that.fullText);case WhisperEngineError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int percent)?  progress,TResult? Function( String text,  Duration start,  Duration end)?  segment,TResult? Function( String fullText)?  done,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case WhisperEngineProgress() when progress != null:
return progress(_that.percent);case WhisperEngineSegment() when segment != null:
return segment(_that.text,_that.start,_that.end);case WhisperEngineDone() when done != null:
return done(_that.fullText);case WhisperEngineError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class WhisperEngineProgress implements WhisperEngineEvent {
  const WhisperEngineProgress({required this.percent});
  

 final  int percent;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhisperEngineProgressCopyWith<WhisperEngineProgress> get copyWith => _$WhisperEngineProgressCopyWithImpl<WhisperEngineProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhisperEngineProgress&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,percent);

@override
String toString() {
  return 'WhisperEngineEvent.progress(percent: $percent)';
}


}

/// @nodoc
abstract mixin class $WhisperEngineProgressCopyWith<$Res> implements $WhisperEngineEventCopyWith<$Res> {
  factory $WhisperEngineProgressCopyWith(WhisperEngineProgress value, $Res Function(WhisperEngineProgress) _then) = _$WhisperEngineProgressCopyWithImpl;
@useResult
$Res call({
 int percent
});




}
/// @nodoc
class _$WhisperEngineProgressCopyWithImpl<$Res>
    implements $WhisperEngineProgressCopyWith<$Res> {
  _$WhisperEngineProgressCopyWithImpl(this._self, this._then);

  final WhisperEngineProgress _self;
  final $Res Function(WhisperEngineProgress) _then;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? percent = null,}) {
  return _then(WhisperEngineProgress(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class WhisperEngineSegment implements WhisperEngineEvent {
  const WhisperEngineSegment({required this.text, required this.start, required this.end});
  

 final  String text;
 final  Duration start;
 final  Duration end;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhisperEngineSegmentCopyWith<WhisperEngineSegment> get copyWith => _$WhisperEngineSegmentCopyWithImpl<WhisperEngineSegment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhisperEngineSegment&&(identical(other.text, text) || other.text == text)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,text,start,end);

@override
String toString() {
  return 'WhisperEngineEvent.segment(text: $text, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $WhisperEngineSegmentCopyWith<$Res> implements $WhisperEngineEventCopyWith<$Res> {
  factory $WhisperEngineSegmentCopyWith(WhisperEngineSegment value, $Res Function(WhisperEngineSegment) _then) = _$WhisperEngineSegmentCopyWithImpl;
@useResult
$Res call({
 String text, Duration start, Duration end
});




}
/// @nodoc
class _$WhisperEngineSegmentCopyWithImpl<$Res>
    implements $WhisperEngineSegmentCopyWith<$Res> {
  _$WhisperEngineSegmentCopyWithImpl(this._self, this._then);

  final WhisperEngineSegment _self;
  final $Res Function(WhisperEngineSegment) _then;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,Object? start = null,Object? end = null,}) {
  return _then(WhisperEngineSegment(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Duration,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class WhisperEngineDone implements WhisperEngineEvent {
  const WhisperEngineDone({required this.fullText});
  

 final  String fullText;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhisperEngineDoneCopyWith<WhisperEngineDone> get copyWith => _$WhisperEngineDoneCopyWithImpl<WhisperEngineDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhisperEngineDone&&(identical(other.fullText, fullText) || other.fullText == fullText));
}


@override
int get hashCode => Object.hash(runtimeType,fullText);

@override
String toString() {
  return 'WhisperEngineEvent.done(fullText: $fullText)';
}


}

/// @nodoc
abstract mixin class $WhisperEngineDoneCopyWith<$Res> implements $WhisperEngineEventCopyWith<$Res> {
  factory $WhisperEngineDoneCopyWith(WhisperEngineDone value, $Res Function(WhisperEngineDone) _then) = _$WhisperEngineDoneCopyWithImpl;
@useResult
$Res call({
 String fullText
});




}
/// @nodoc
class _$WhisperEngineDoneCopyWithImpl<$Res>
    implements $WhisperEngineDoneCopyWith<$Res> {
  _$WhisperEngineDoneCopyWithImpl(this._self, this._then);

  final WhisperEngineDone _self;
  final $Res Function(WhisperEngineDone) _then;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fullText = null,}) {
  return _then(WhisperEngineDone(
fullText: null == fullText ? _self.fullText : fullText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class WhisperEngineError implements WhisperEngineEvent {
  const WhisperEngineError({required this.message});
  

 final  String message;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhisperEngineErrorCopyWith<WhisperEngineError> get copyWith => _$WhisperEngineErrorCopyWithImpl<WhisperEngineError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhisperEngineError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'WhisperEngineEvent.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $WhisperEngineErrorCopyWith<$Res> implements $WhisperEngineEventCopyWith<$Res> {
  factory $WhisperEngineErrorCopyWith(WhisperEngineError value, $Res Function(WhisperEngineError) _then) = _$WhisperEngineErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$WhisperEngineErrorCopyWithImpl<$Res>
    implements $WhisperEngineErrorCopyWith<$Res> {
  _$WhisperEngineErrorCopyWithImpl(this._self, this._then);

  final WhisperEngineError _self;
  final $Res Function(WhisperEngineError) _then;

/// Create a copy of WhisperEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(WhisperEngineError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
