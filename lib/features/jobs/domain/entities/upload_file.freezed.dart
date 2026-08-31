// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadFile {

 String get name; String get path; int get sizeBytes; String get contentType;
/// Create a copy of UploadFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadFileCopyWith<UploadFile> get copyWith => _$UploadFileCopyWithImpl<UploadFile>(this as UploadFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadFile&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,sizeBytes,contentType);

@override
String toString() {
  return 'UploadFile(name: $name, path: $path, sizeBytes: $sizeBytes, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $UploadFileCopyWith<$Res>  {
  factory $UploadFileCopyWith(UploadFile value, $Res Function(UploadFile) _then) = _$UploadFileCopyWithImpl;
@useResult
$Res call({
 String name, String path, int sizeBytes, String contentType
});




}
/// @nodoc
class _$UploadFileCopyWithImpl<$Res>
    implements $UploadFileCopyWith<$Res> {
  _$UploadFileCopyWithImpl(this._self, this._then);

  final UploadFile _self;
  final $Res Function(UploadFile) _then;

/// Create a copy of UploadFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? sizeBytes = null,Object? contentType = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadFile].
extension UploadFilePatterns on UploadFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadFile value)  $default,){
final _that = this;
switch (_that) {
case _UploadFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadFile value)?  $default,){
final _that = this;
switch (_that) {
case _UploadFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  int sizeBytes,  String contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadFile() when $default != null:
return $default(_that.name,_that.path,_that.sizeBytes,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  int sizeBytes,  String contentType)  $default,) {final _that = this;
switch (_that) {
case _UploadFile():
return $default(_that.name,_that.path,_that.sizeBytes,_that.contentType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  int sizeBytes,  String contentType)?  $default,) {final _that = this;
switch (_that) {
case _UploadFile() when $default != null:
return $default(_that.name,_that.path,_that.sizeBytes,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc


class _UploadFile implements UploadFile {
  const _UploadFile({required this.name, required this.path, required this.sizeBytes, required this.contentType});
  

@override final  String name;
@override final  String path;
@override final  int sizeBytes;
@override final  String contentType;

/// Create a copy of UploadFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadFileCopyWith<_UploadFile> get copyWith => __$UploadFileCopyWithImpl<_UploadFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadFile&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,sizeBytes,contentType);

@override
String toString() {
  return 'UploadFile(name: $name, path: $path, sizeBytes: $sizeBytes, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$UploadFileCopyWith<$Res> implements $UploadFileCopyWith<$Res> {
  factory _$UploadFileCopyWith(_UploadFile value, $Res Function(_UploadFile) _then) = __$UploadFileCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, int sizeBytes, String contentType
});




}
/// @nodoc
class __$UploadFileCopyWithImpl<$Res>
    implements _$UploadFileCopyWith<$Res> {
  __$UploadFileCopyWithImpl(this._self, this._then);

  final _UploadFile _self;
  final $Res Function(_UploadFile) _then;

/// Create a copy of UploadFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? sizeBytes = null,Object? contentType = null,}) {
  return _then(_UploadFile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
