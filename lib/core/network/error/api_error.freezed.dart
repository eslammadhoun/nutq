// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiError()';
}


}

/// @nodoc
class $ApiErrorCopyWith<$Res>  {
$ApiErrorCopyWith(ApiError _, $Res Function(ApiError) __);
}


/// Adds pattern-matching-related methods to [ApiError].
extension ApiErrorPatterns on ApiError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkError value)?  network,TResult Function( ServerUnreachableError value)?  serverUnreachable,TResult Function( TimeoutError value)?  timeout,TResult Function( UnauthorizedError value)?  unauthorized,TResult Function( ValidationError value)?  validation,TResult Function( ServerError value)?  server,TResult Function( UnknownError value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case ServerUnreachableError() when serverUnreachable != null:
return serverUnreachable(_that);case TimeoutError() when timeout != null:
return timeout(_that);case UnauthorizedError() when unauthorized != null:
return unauthorized(_that);case ValidationError() when validation != null:
return validation(_that);case ServerError() when server != null:
return server(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkError value)  network,required TResult Function( ServerUnreachableError value)  serverUnreachable,required TResult Function( TimeoutError value)  timeout,required TResult Function( UnauthorizedError value)  unauthorized,required TResult Function( ValidationError value)  validation,required TResult Function( ServerError value)  server,required TResult Function( UnknownError value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkError():
return network(_that);case ServerUnreachableError():
return serverUnreachable(_that);case TimeoutError():
return timeout(_that);case UnauthorizedError():
return unauthorized(_that);case ValidationError():
return validation(_that);case ServerError():
return server(_that);case UnknownError():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkError value)?  network,TResult? Function( ServerUnreachableError value)?  serverUnreachable,TResult? Function( TimeoutError value)?  timeout,TResult? Function( UnauthorizedError value)?  unauthorized,TResult? Function( ValidationError value)?  validation,TResult? Function( ServerError value)?  server,TResult? Function( UnknownError value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case ServerUnreachableError() when serverUnreachable != null:
return serverUnreachable(_that);case TimeoutError() when timeout != null:
return timeout(_that);case UnauthorizedError() when unauthorized != null:
return unauthorized(_that);case ValidationError() when validation != null:
return validation(_that);case ServerError() when server != null:
return server(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  network,TResult Function()?  serverUnreachable,TResult Function()?  timeout,TResult Function()?  unauthorized,TResult Function( Map<String, String> fieldErrors)?  validation,TResult Function( String message,  int? statusCode)?  server,TResult Function( String message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network();case ServerUnreachableError() when serverUnreachable != null:
return serverUnreachable();case TimeoutError() when timeout != null:
return timeout();case UnauthorizedError() when unauthorized != null:
return unauthorized();case ValidationError() when validation != null:
return validation(_that.fieldErrors);case ServerError() when server != null:
return server(_that.message,_that.statusCode);case UnknownError() when unknown != null:
return unknown(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  network,required TResult Function()  serverUnreachable,required TResult Function()  timeout,required TResult Function()  unauthorized,required TResult Function( Map<String, String> fieldErrors)  validation,required TResult Function( String message,  int? statusCode)  server,required TResult Function( String message)  unknown,}) {final _that = this;
switch (_that) {
case NetworkError():
return network();case ServerUnreachableError():
return serverUnreachable();case TimeoutError():
return timeout();case UnauthorizedError():
return unauthorized();case ValidationError():
return validation(_that.fieldErrors);case ServerError():
return server(_that.message,_that.statusCode);case UnknownError():
return unknown(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  network,TResult? Function()?  serverUnreachable,TResult? Function()?  timeout,TResult? Function()?  unauthorized,TResult? Function( Map<String, String> fieldErrors)?  validation,TResult? Function( String message,  int? statusCode)?  server,TResult? Function( String message)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network();case ServerUnreachableError() when serverUnreachable != null:
return serverUnreachable();case TimeoutError() when timeout != null:
return timeout();case UnauthorizedError() when unauthorized != null:
return unauthorized();case ValidationError() when validation != null:
return validation(_that.fieldErrors);case ServerError() when server != null:
return server(_that.message,_that.statusCode);case UnknownError() when unknown != null:
return unknown(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NetworkError implements ApiError {
  const NetworkError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiError.network()';
}


}




/// @nodoc


class ServerUnreachableError implements ApiError {
  const ServerUnreachableError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerUnreachableError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiError.serverUnreachable()';
}


}




/// @nodoc


class TimeoutError implements ApiError {
  const TimeoutError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiError.timeout()';
}


}




/// @nodoc


class UnauthorizedError implements ApiError {
  const UnauthorizedError();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthorizedError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiError.unauthorized()';
}


}




/// @nodoc


class ValidationError implements ApiError {
  const ValidationError(final  Map<String, String> fieldErrors): _fieldErrors = fieldErrors;
  

 final  Map<String, String> _fieldErrors;
 Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationErrorCopyWith<ValidationError> get copyWith => _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationError&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'ApiError.validation(fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res> implements $ApiErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(ValidationError value, $Res Function(ValidationError) _then) = _$ValidationErrorCopyWithImpl;
@useResult
$Res call({
 Map<String, String> fieldErrors
});




}
/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fieldErrors = null,}) {
  return _then(ValidationError(
null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc


class ServerError implements ApiError {
  const ServerError(this.message, this.statusCode);
  

 final  String message;
 final  int? statusCode;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorCopyWith<ServerError> get copyWith => _$ServerErrorCopyWithImpl<ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&(identical(other.message, message) || other.message == message)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,statusCode);

@override
String toString() {
  return 'ApiError.server(message: $message, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res> implements $ApiErrorCopyWith<$Res> {
  factory $ServerErrorCopyWith(ServerError value, $Res Function(ServerError) _then) = _$ServerErrorCopyWithImpl;
@useResult
$Res call({
 String message, int? statusCode
});




}
/// @nodoc
class _$ServerErrorCopyWithImpl<$Res>
    implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? statusCode = freezed,}) {
  return _then(ServerError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class UnknownError implements ApiError {
  const UnknownError(this.message);
  

 final  String message;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownErrorCopyWith<UnknownError> get copyWith => _$UnknownErrorCopyWithImpl<UnknownError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ApiError.unknown(message: $message)';
}


}

/// @nodoc
abstract mixin class $UnknownErrorCopyWith<$Res> implements $ApiErrorCopyWith<$Res> {
  factory $UnknownErrorCopyWith(UnknownError value, $Res Function(UnknownError) _then) = _$UnknownErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$UnknownErrorCopyWithImpl<$Res>
    implements $UnknownErrorCopyWith<$Res> {
  _$UnknownErrorCopyWithImpl(this._self, this._then);

  final UnknownError _self;
  final $Res Function(UnknownError) _then;

/// Create a copy of ApiError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UnknownError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
