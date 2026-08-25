// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_slot_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadSlotResponse {

@JsonKey(name: 'upload_url') String get uploadUrl;@JsonKey(name: 'upload_token') String get uploadToken;@JsonKey(name: 'expires_in_seconds') int get expiresInSeconds;
/// Create a copy of UploadSlotResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadSlotResponseCopyWith<UploadSlotResponse> get copyWith => _$UploadSlotResponseCopyWithImpl<UploadSlotResponse>(this as UploadSlotResponse, _$identity);

  /// Serializes this UploadSlotResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadSlotResponse&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.uploadToken, uploadToken) || other.uploadToken == uploadToken)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uploadUrl,uploadToken,expiresInSeconds);

@override
String toString() {
  return 'UploadSlotResponse(uploadUrl: $uploadUrl, uploadToken: $uploadToken, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class $UploadSlotResponseCopyWith<$Res>  {
  factory $UploadSlotResponseCopyWith(UploadSlotResponse value, $Res Function(UploadSlotResponse) _then) = _$UploadSlotResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'upload_url') String uploadUrl,@JsonKey(name: 'upload_token') String uploadToken,@JsonKey(name: 'expires_in_seconds') int expiresInSeconds
});




}
/// @nodoc
class _$UploadSlotResponseCopyWithImpl<$Res>
    implements $UploadSlotResponseCopyWith<$Res> {
  _$UploadSlotResponseCopyWithImpl(this._self, this._then);

  final UploadSlotResponse _self;
  final $Res Function(UploadSlotResponse) _then;

/// Create a copy of UploadSlotResponse
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


/// Adds pattern-matching-related methods to [UploadSlotResponse].
extension UploadSlotResponsePatterns on UploadSlotResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadSlotResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadSlotResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadSlotResponse value)  $default,){
final _that = this;
switch (_that) {
case _UploadSlotResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadSlotResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UploadSlotResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'upload_url')  String uploadUrl, @JsonKey(name: 'upload_token')  String uploadToken, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadSlotResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'upload_url')  String uploadUrl, @JsonKey(name: 'upload_token')  String uploadToken, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)  $default,) {final _that = this;
switch (_that) {
case _UploadSlotResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'upload_url')  String uploadUrl, @JsonKey(name: 'upload_token')  String uploadToken, @JsonKey(name: 'expires_in_seconds')  int expiresInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _UploadSlotResponse() when $default != null:
return $default(_that.uploadUrl,_that.uploadToken,_that.expiresInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadSlotResponse implements UploadSlotResponse {
  const _UploadSlotResponse({@JsonKey(name: 'upload_url') required this.uploadUrl, @JsonKey(name: 'upload_token') required this.uploadToken, @JsonKey(name: 'expires_in_seconds') required this.expiresInSeconds});
  factory _UploadSlotResponse.fromJson(Map<String, dynamic> json) => _$UploadSlotResponseFromJson(json);

@override@JsonKey(name: 'upload_url') final  String uploadUrl;
@override@JsonKey(name: 'upload_token') final  String uploadToken;
@override@JsonKey(name: 'expires_in_seconds') final  int expiresInSeconds;

/// Create a copy of UploadSlotResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadSlotResponseCopyWith<_UploadSlotResponse> get copyWith => __$UploadSlotResponseCopyWithImpl<_UploadSlotResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadSlotResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadSlotResponse&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.uploadToken, uploadToken) || other.uploadToken == uploadToken)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uploadUrl,uploadToken,expiresInSeconds);

@override
String toString() {
  return 'UploadSlotResponse(uploadUrl: $uploadUrl, uploadToken: $uploadToken, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class _$UploadSlotResponseCopyWith<$Res> implements $UploadSlotResponseCopyWith<$Res> {
  factory _$UploadSlotResponseCopyWith(_UploadSlotResponse value, $Res Function(_UploadSlotResponse) _then) = __$UploadSlotResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'upload_url') String uploadUrl,@JsonKey(name: 'upload_token') String uploadToken,@JsonKey(name: 'expires_in_seconds') int expiresInSeconds
});




}
/// @nodoc
class __$UploadSlotResponseCopyWithImpl<$Res>
    implements _$UploadSlotResponseCopyWith<$Res> {
  __$UploadSlotResponseCopyWithImpl(this._self, this._then);

  final _UploadSlotResponse _self;
  final $Res Function(_UploadSlotResponse) _then;

/// Create a copy of UploadSlotResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadUrl = null,Object? uploadToken = null,Object? expiresInSeconds = null,}) {
  return _then(_UploadSlotResponse(
uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,uploadToken: null == uploadToken ? _self.uploadToken : uploadToken // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
