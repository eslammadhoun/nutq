// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_engine_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LlmEngineEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmEngineEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LlmEngineEvent()';
}


}

/// @nodoc
class $LlmEngineEventCopyWith<$Res>  {
$LlmEngineEventCopyWith(LlmEngineEvent _, $Res Function(LlmEngineEvent) __);
}


/// Adds pattern-matching-related methods to [LlmEngineEvent].
extension LlmEngineEventPatterns on LlmEngineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LlmEngineToken value)?  token,TResult Function( LlmEngineDone value)?  done,TResult Function( LlmEngineError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LlmEngineToken() when token != null:
return token(_that);case LlmEngineDone() when done != null:
return done(_that);case LlmEngineError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LlmEngineToken value)  token,required TResult Function( LlmEngineDone value)  done,required TResult Function( LlmEngineError value)  error,}){
final _that = this;
switch (_that) {
case LlmEngineToken():
return token(_that);case LlmEngineDone():
return done(_that);case LlmEngineError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LlmEngineToken value)?  token,TResult? Function( LlmEngineDone value)?  done,TResult? Function( LlmEngineError value)?  error,}){
final _that = this;
switch (_that) {
case LlmEngineToken() when token != null:
return token(_that);case LlmEngineDone() when done != null:
return done(_that);case LlmEngineError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  token,TResult Function( String fullText)?  done,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LlmEngineToken() when token != null:
return token(_that.text);case LlmEngineDone() when done != null:
return done(_that.fullText);case LlmEngineError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  token,required TResult Function( String fullText)  done,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case LlmEngineToken():
return token(_that.text);case LlmEngineDone():
return done(_that.fullText);case LlmEngineError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  token,TResult? Function( String fullText)?  done,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case LlmEngineToken() when token != null:
return token(_that.text);case LlmEngineDone() when done != null:
return done(_that.fullText);case LlmEngineError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LlmEngineToken implements LlmEngineEvent {
  const LlmEngineToken({required this.text});
  

 final  String text;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmEngineTokenCopyWith<LlmEngineToken> get copyWith => _$LlmEngineTokenCopyWithImpl<LlmEngineToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmEngineToken&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'LlmEngineEvent.token(text: $text)';
}


}

/// @nodoc
abstract mixin class $LlmEngineTokenCopyWith<$Res> implements $LlmEngineEventCopyWith<$Res> {
  factory $LlmEngineTokenCopyWith(LlmEngineToken value, $Res Function(LlmEngineToken) _then) = _$LlmEngineTokenCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$LlmEngineTokenCopyWithImpl<$Res>
    implements $LlmEngineTokenCopyWith<$Res> {
  _$LlmEngineTokenCopyWithImpl(this._self, this._then);

  final LlmEngineToken _self;
  final $Res Function(LlmEngineToken) _then;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(LlmEngineToken(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LlmEngineDone implements LlmEngineEvent {
  const LlmEngineDone({required this.fullText});
  

 final  String fullText;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmEngineDoneCopyWith<LlmEngineDone> get copyWith => _$LlmEngineDoneCopyWithImpl<LlmEngineDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmEngineDone&&(identical(other.fullText, fullText) || other.fullText == fullText));
}


@override
int get hashCode => Object.hash(runtimeType,fullText);

@override
String toString() {
  return 'LlmEngineEvent.done(fullText: $fullText)';
}


}

/// @nodoc
abstract mixin class $LlmEngineDoneCopyWith<$Res> implements $LlmEngineEventCopyWith<$Res> {
  factory $LlmEngineDoneCopyWith(LlmEngineDone value, $Res Function(LlmEngineDone) _then) = _$LlmEngineDoneCopyWithImpl;
@useResult
$Res call({
 String fullText
});




}
/// @nodoc
class _$LlmEngineDoneCopyWithImpl<$Res>
    implements $LlmEngineDoneCopyWith<$Res> {
  _$LlmEngineDoneCopyWithImpl(this._self, this._then);

  final LlmEngineDone _self;
  final $Res Function(LlmEngineDone) _then;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fullText = null,}) {
  return _then(LlmEngineDone(
fullText: null == fullText ? _self.fullText : fullText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LlmEngineError implements LlmEngineEvent {
  const LlmEngineError({required this.message});
  

 final  String message;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmEngineErrorCopyWith<LlmEngineError> get copyWith => _$LlmEngineErrorCopyWithImpl<LlmEngineError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmEngineError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LlmEngineEvent.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $LlmEngineErrorCopyWith<$Res> implements $LlmEngineEventCopyWith<$Res> {
  factory $LlmEngineErrorCopyWith(LlmEngineError value, $Res Function(LlmEngineError) _then) = _$LlmEngineErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$LlmEngineErrorCopyWithImpl<$Res>
    implements $LlmEngineErrorCopyWith<$Res> {
  _$LlmEngineErrorCopyWithImpl(this._self, this._then);

  final LlmEngineError _self;
  final $Res Function(LlmEngineError) _then;

/// Create a copy of LlmEngineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(LlmEngineError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
