// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summarization_pipeline_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SummarizationPipelineEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummarizationPipelineEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SummarizationPipelineEvent()';
}


}

/// @nodoc
class $SummarizationPipelineEventCopyWith<$Res>  {
$SummarizationPipelineEventCopyWith(SummarizationPipelineEvent _, $Res Function(SummarizationPipelineEvent) __);
}


/// Adds pattern-matching-related methods to [SummarizationPipelineEvent].
extension SummarizationPipelineEventPatterns on SummarizationPipelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SummarizationPipelineTextBatch value)?  textBatch,TResult Function( SummarizationPipelineDone value)?  done,TResult Function( SummarizationPipelineError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch() when textBatch != null:
return textBatch(_that);case SummarizationPipelineDone() when done != null:
return done(_that);case SummarizationPipelineError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SummarizationPipelineTextBatch value)  textBatch,required TResult Function( SummarizationPipelineDone value)  done,required TResult Function( SummarizationPipelineError value)  error,}){
final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch():
return textBatch(_that);case SummarizationPipelineDone():
return done(_that);case SummarizationPipelineError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SummarizationPipelineTextBatch value)?  textBatch,TResult? Function( SummarizationPipelineDone value)?  done,TResult? Function( SummarizationPipelineError value)?  error,}){
final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch() when textBatch != null:
return textBatch(_that);case SummarizationPipelineDone() when done != null:
return done(_that);case SummarizationPipelineError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  textBatch,TResult Function( Summary summary)?  done,TResult Function( ApiError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch() when textBatch != null:
return textBatch(_that.text);case SummarizationPipelineDone() when done != null:
return done(_that.summary);case SummarizationPipelineError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  textBatch,required TResult Function( Summary summary)  done,required TResult Function( ApiError error)  error,}) {final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch():
return textBatch(_that.text);case SummarizationPipelineDone():
return done(_that.summary);case SummarizationPipelineError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  textBatch,TResult? Function( Summary summary)?  done,TResult? Function( ApiError error)?  error,}) {final _that = this;
switch (_that) {
case SummarizationPipelineTextBatch() when textBatch != null:
return textBatch(_that.text);case SummarizationPipelineDone() when done != null:
return done(_that.summary);case SummarizationPipelineError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class SummarizationPipelineTextBatch implements SummarizationPipelineEvent {
  const SummarizationPipelineTextBatch({required this.text});
  

 final  String text;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummarizationPipelineTextBatchCopyWith<SummarizationPipelineTextBatch> get copyWith => _$SummarizationPipelineTextBatchCopyWithImpl<SummarizationPipelineTextBatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummarizationPipelineTextBatch&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'SummarizationPipelineEvent.textBatch(text: $text)';
}


}

/// @nodoc
abstract mixin class $SummarizationPipelineTextBatchCopyWith<$Res> implements $SummarizationPipelineEventCopyWith<$Res> {
  factory $SummarizationPipelineTextBatchCopyWith(SummarizationPipelineTextBatch value, $Res Function(SummarizationPipelineTextBatch) _then) = _$SummarizationPipelineTextBatchCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$SummarizationPipelineTextBatchCopyWithImpl<$Res>
    implements $SummarizationPipelineTextBatchCopyWith<$Res> {
  _$SummarizationPipelineTextBatchCopyWithImpl(this._self, this._then);

  final SummarizationPipelineTextBatch _self;
  final $Res Function(SummarizationPipelineTextBatch) _then;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(SummarizationPipelineTextBatch(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SummarizationPipelineDone implements SummarizationPipelineEvent {
  const SummarizationPipelineDone({required this.summary});
  

 final  Summary summary;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummarizationPipelineDoneCopyWith<SummarizationPipelineDone> get copyWith => _$SummarizationPipelineDoneCopyWithImpl<SummarizationPipelineDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummarizationPipelineDone&&(identical(other.summary, summary) || other.summary == summary));
}


@override
int get hashCode => Object.hash(runtimeType,summary);

@override
String toString() {
  return 'SummarizationPipelineEvent.done(summary: $summary)';
}


}

/// @nodoc
abstract mixin class $SummarizationPipelineDoneCopyWith<$Res> implements $SummarizationPipelineEventCopyWith<$Res> {
  factory $SummarizationPipelineDoneCopyWith(SummarizationPipelineDone value, $Res Function(SummarizationPipelineDone) _then) = _$SummarizationPipelineDoneCopyWithImpl;
@useResult
$Res call({
 Summary summary
});


$SummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$SummarizationPipelineDoneCopyWithImpl<$Res>
    implements $SummarizationPipelineDoneCopyWith<$Res> {
  _$SummarizationPipelineDoneCopyWithImpl(this._self, this._then);

  final SummarizationPipelineDone _self;
  final $Res Function(SummarizationPipelineDone) _then;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? summary = null,}) {
  return _then(SummarizationPipelineDone(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Summary,
  ));
}

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summary {
  
  return $SummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc


class SummarizationPipelineError implements SummarizationPipelineEvent {
  const SummarizationPipelineError({required this.error});
  

 final  ApiError error;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummarizationPipelineErrorCopyWith<SummarizationPipelineError> get copyWith => _$SummarizationPipelineErrorCopyWithImpl<SummarizationPipelineError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummarizationPipelineError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SummarizationPipelineEvent.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $SummarizationPipelineErrorCopyWith<$Res> implements $SummarizationPipelineEventCopyWith<$Res> {
  factory $SummarizationPipelineErrorCopyWith(SummarizationPipelineError value, $Res Function(SummarizationPipelineError) _then) = _$SummarizationPipelineErrorCopyWithImpl;
@useResult
$Res call({
 ApiError error
});


$ApiErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$SummarizationPipelineErrorCopyWithImpl<$Res>
    implements $SummarizationPipelineErrorCopyWith<$Res> {
  _$SummarizationPipelineErrorCopyWithImpl(this._self, this._then);

  final SummarizationPipelineError _self;
  final $Res Function(SummarizationPipelineError) _then;

/// Create a copy of SummarizationPipelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(SummarizationPipelineError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiError,
  ));
}

/// Create a copy of SummarizationPipelineEvent
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
