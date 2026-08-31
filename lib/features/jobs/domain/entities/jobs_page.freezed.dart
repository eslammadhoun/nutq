// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jobs_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JobsPage {

 List<JobEntity> get items; String? get nextCursor;
/// Create a copy of JobsPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobsPageCopyWith<JobsPage> get copyWith => _$JobsPageCopyWithImpl<JobsPage>(this as JobsPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobsPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'JobsPage(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $JobsPageCopyWith<$Res>  {
  factory $JobsPageCopyWith(JobsPage value, $Res Function(JobsPage) _then) = _$JobsPageCopyWithImpl;
@useResult
$Res call({
 List<JobEntity> items, String? nextCursor
});




}
/// @nodoc
class _$JobsPageCopyWithImpl<$Res>
    implements $JobsPageCopyWith<$Res> {
  _$JobsPageCopyWithImpl(this._self, this._then);

  final JobsPage _self;
  final $Res Function(JobsPage) _then;

/// Create a copy of JobsPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<JobEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobsPage].
extension JobsPagePatterns on JobsPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobsPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobsPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobsPage value)  $default,){
final _that = this;
switch (_that) {
case _JobsPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobsPage value)?  $default,){
final _that = this;
switch (_that) {
case _JobsPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<JobEntity> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobsPage() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<JobEntity> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _JobsPage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<JobEntity> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _JobsPage() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _JobsPage implements JobsPage {
  const _JobsPage({required final  List<JobEntity> items, this.nextCursor}): _items = items;
  

 final  List<JobEntity> _items;
@override List<JobEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of JobsPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobsPageCopyWith<_JobsPage> get copyWith => __$JobsPageCopyWithImpl<_JobsPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobsPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'JobsPage(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$JobsPageCopyWith<$Res> implements $JobsPageCopyWith<$Res> {
  factory _$JobsPageCopyWith(_JobsPage value, $Res Function(_JobsPage) _then) = __$JobsPageCopyWithImpl;
@override @useResult
$Res call({
 List<JobEntity> items, String? nextCursor
});




}
/// @nodoc
class __$JobsPageCopyWithImpl<$Res>
    implements _$JobsPageCopyWith<$Res> {
  __$JobsPageCopyWithImpl(this._self, this._then);

  final _JobsPage _self;
  final $Res Function(_JobsPage) _then;

/// Create a copy of JobsPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_JobsPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<JobEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
