// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_job_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewJobState {

 JobUploadType get jobUploadType; JobLanguage get jobLanguage; bool get idempotencyKey;
/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewJobStateCopyWith<NewJobState> get copyWith => _$NewJobStateCopyWithImpl<NewJobState>(this as NewJobState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewJobState&&(identical(other.jobUploadType, jobUploadType) || other.jobUploadType == jobUploadType)&&(identical(other.jobLanguage, jobLanguage) || other.jobLanguage == jobLanguage)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,jobUploadType,jobLanguage,idempotencyKey);

@override
String toString() {
  return 'NewJobState(jobUploadType: $jobUploadType, jobLanguage: $jobLanguage, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $NewJobStateCopyWith<$Res>  {
  factory $NewJobStateCopyWith(NewJobState value, $Res Function(NewJobState) _then) = _$NewJobStateCopyWithImpl;
@useResult
$Res call({
 JobUploadType jobUploadType, JobLanguage jobLanguage, bool idempotencyKey
});




}
/// @nodoc
class _$NewJobStateCopyWithImpl<$Res>
    implements $NewJobStateCopyWith<$Res> {
  _$NewJobStateCopyWithImpl(this._self, this._then);

  final NewJobState _self;
  final $Res Function(NewJobState) _then;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobUploadType = null,Object? jobLanguage = null,Object? idempotencyKey = null,}) {
  return _then(_self.copyWith(
jobUploadType: null == jobUploadType ? _self.jobUploadType : jobUploadType // ignore: cast_nullable_to_non_nullable
as JobUploadType,jobLanguage: null == jobLanguage ? _self.jobLanguage : jobLanguage // ignore: cast_nullable_to_non_nullable
as JobLanguage,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NewJobState].
extension NewJobStatePatterns on NewJobState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewJobState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewJobState value)  $default,){
final _that = this;
switch (_that) {
case _NewJobState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewJobState value)?  $default,){
final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JobUploadType jobUploadType,  JobLanguage jobLanguage,  bool idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
return $default(_that.jobUploadType,_that.jobLanguage,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JobUploadType jobUploadType,  JobLanguage jobLanguage,  bool idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _NewJobState():
return $default(_that.jobUploadType,_that.jobLanguage,_that.idempotencyKey);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JobUploadType jobUploadType,  JobLanguage jobLanguage,  bool idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _NewJobState() when $default != null:
return $default(_that.jobUploadType,_that.jobLanguage,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _NewJobState implements NewJobState {
  const _NewJobState({this.jobUploadType = JobUploadType.text, this.jobLanguage = JobLanguage.ar, this.idempotencyKey = false});
  

@override@JsonKey() final  JobUploadType jobUploadType;
@override@JsonKey() final  JobLanguage jobLanguage;
@override@JsonKey() final  bool idempotencyKey;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewJobStateCopyWith<_NewJobState> get copyWith => __$NewJobStateCopyWithImpl<_NewJobState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewJobState&&(identical(other.jobUploadType, jobUploadType) || other.jobUploadType == jobUploadType)&&(identical(other.jobLanguage, jobLanguage) || other.jobLanguage == jobLanguage)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,jobUploadType,jobLanguage,idempotencyKey);

@override
String toString() {
  return 'NewJobState(jobUploadType: $jobUploadType, jobLanguage: $jobLanguage, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$NewJobStateCopyWith<$Res> implements $NewJobStateCopyWith<$Res> {
  factory _$NewJobStateCopyWith(_NewJobState value, $Res Function(_NewJobState) _then) = __$NewJobStateCopyWithImpl;
@override @useResult
$Res call({
 JobUploadType jobUploadType, JobLanguage jobLanguage, bool idempotencyKey
});




}
/// @nodoc
class __$NewJobStateCopyWithImpl<$Res>
    implements _$NewJobStateCopyWith<$Res> {
  __$NewJobStateCopyWithImpl(this._self, this._then);

  final _NewJobState _self;
  final $Res Function(_NewJobState) _then;

/// Create a copy of NewJobState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobUploadType = null,Object? jobLanguage = null,Object? idempotencyKey = null,}) {
  return _then(_NewJobState(
jobUploadType: null == jobUploadType ? _self.jobUploadType : jobUploadType // ignore: cast_nullable_to_non_nullable
as JobUploadType,jobLanguage: null == jobLanguage ? _self.jobLanguage : jobLanguage // ignore: cast_nullable_to_non_nullable
as JobLanguage,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
