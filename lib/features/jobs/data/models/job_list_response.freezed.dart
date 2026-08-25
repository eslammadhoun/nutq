// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobListResponse {

 List<JobResponse> get items;@JsonKey(name: 'next_cursor') String? get nextCursor;
/// Create a copy of JobListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobListResponseCopyWith<JobListResponse> get copyWith => _$JobListResponseCopyWithImpl<JobListResponse>(this as JobListResponse, _$identity);

  /// Serializes this JobListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobListResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'JobListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $JobListResponseCopyWith<$Res>  {
  factory $JobListResponseCopyWith(JobListResponse value, $Res Function(JobListResponse) _then) = _$JobListResponseCopyWithImpl;
@useResult
$Res call({
 List<JobResponse> items,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class _$JobListResponseCopyWithImpl<$Res>
    implements $JobListResponseCopyWith<$Res> {
  _$JobListResponseCopyWithImpl(this._self, this._then);

  final JobListResponse _self;
  final $Res Function(JobListResponse) _then;

/// Create a copy of JobListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<JobResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobListResponse].
extension JobListResponsePatterns on JobListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobListResponse value)  $default,){
final _that = this;
switch (_that) {
case _JobListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _JobListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<JobResponse> items, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<JobResponse> items, @JsonKey(name: 'next_cursor')  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _JobListResponse():
return $default(_that.items,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<JobResponse> items, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _JobListResponse() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobListResponse implements JobListResponse {
  const _JobListResponse({required final  List<JobResponse> items, @JsonKey(name: 'next_cursor') this.nextCursor}): _items = items;
  factory _JobListResponse.fromJson(Map<String, dynamic> json) => _$JobListResponseFromJson(json);

 final  List<JobResponse> _items;
@override List<JobResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;

/// Create a copy of JobListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobListResponseCopyWith<_JobListResponse> get copyWith => __$JobListResponseCopyWithImpl<_JobListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobListResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'JobListResponse(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$JobListResponseCopyWith<$Res> implements $JobListResponseCopyWith<$Res> {
  factory _$JobListResponseCopyWith(_JobListResponse value, $Res Function(_JobListResponse) _then) = __$JobListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<JobResponse> items,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class __$JobListResponseCopyWithImpl<$Res>
    implements _$JobListResponseCopyWith<$Res> {
  __$JobListResponseCopyWithImpl(this._self, this._then);

  final _JobListResponse _self;
  final $Res Function(_JobListResponse) _then;

/// Create a copy of JobListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_JobListResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<JobResponse>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
