// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadSlot {

 String get uploadUrl; String get uploadToken; int get expiresInSeconds;
/// Create a copy of UploadSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadSlotCopyWith<UploadSlot> get copyWith => _$UploadSlotCopyWithImpl<UploadSlot>(this as UploadSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadSlot&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.uploadToken, uploadToken) || other.uploadToken == uploadToken)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,uploadUrl,uploadToken,expiresInSeconds);

@override
String toString() {
  return 'UploadSlot(uploadUrl: $uploadUrl, uploadToken: $uploadToken, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class $UploadSlotCopyWith<$Res>  {
  factory $UploadSlotCopyWith(UploadSlot value, $Res Function(UploadSlot) _then) = _$UploadSlotCopyWithImpl;
@useResult
$Res call({
 String uploadUrl, String uploadToken, int expiresInSeconds
});




}
/// @nodoc
class _$UploadSlotCopyWithImpl<$Res>
    implements $UploadSlotCopyWith<$Res> {
  _$UploadSlotCopyWithImpl(this._self, this._then);

  final UploadSlot _self;
  final $Res Function(UploadSlot) _then;

/// Create a copy of UploadSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadUrl = null,Object? uploadToken = null,Object? expiresInSeconds = null,}) {
  return _then(_self.copyWith(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,uploadToken: null == uploadToken ? _self.uploadToken : uploadToken // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadSlot].
extension UploadSlotPatterns on UploadSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadSlot value)  $default,){
final _that = this;
switch (_that) {
case _UploadSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadSlot value)?  $default,){
final _that = this;
switch (_that) {
case _UploadSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uploadUrl,  String uploadToken,  int expiresInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadSlot() when $default != null:
return $default(_that.uploadUrl,_that.uploadToken,_that.expiresInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uploadUrl,  String uploadToken,  int expiresInSeconds)  $default,) {final _that = this;
switch (_that) {
case _UploadSlot():
return $default(_that.uploadUrl,_that.uploadToken,_that.expiresInSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uploadUrl,  String uploadToken,  int expiresInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _UploadSlot() when $default != null:
return $default(_that.uploadUrl,_that.uploadToken,_that.expiresInSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _UploadSlot implements UploadSlot {
  const _UploadSlot({required this.uploadUrl, required this.uploadToken, required this.expiresInSeconds});
  

@override final  String uploadUrl;
@override final  String uploadToken;
@override final  int expiresInSeconds;

/// Create a copy of UploadSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadSlotCopyWith<_UploadSlot> get copyWith => __$UploadSlotCopyWithImpl<_UploadSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadSlot&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.uploadToken, uploadToken) || other.uploadToken == uploadToken)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,uploadUrl,uploadToken,expiresInSeconds);

@override
String toString() {
  return 'UploadSlot(uploadUrl: $uploadUrl, uploadToken: $uploadToken, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class _$UploadSlotCopyWith<$Res> implements $UploadSlotCopyWith<$Res> {
  factory _$UploadSlotCopyWith(_UploadSlot value, $Res Function(_UploadSlot) _then) = __$UploadSlotCopyWithImpl;
@override @useResult
$Res call({
 String uploadUrl, String uploadToken, int expiresInSeconds
});




}
/// @nodoc
class __$UploadSlotCopyWithImpl<$Res>
    implements _$UploadSlotCopyWith<$Res> {
  __$UploadSlotCopyWithImpl(this._self, this._then);

  final _UploadSlot _self;
  final $Res Function(_UploadSlot) _then;

/// Create a copy of UploadSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadUrl = null,Object? uploadToken = null,Object? expiresInSeconds = null,}) {
  return _then(_UploadSlot(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,uploadToken: null == uploadToken ? _self.uploadToken : uploadToken // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
