// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_update_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JobUpdateEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JobUpdateEvent()';
}


}

/// @nodoc
class $JobUpdateEventCopyWith<$Res>  {
$JobUpdateEventCopyWith(JobUpdateEvent _, $Res Function(JobUpdateEvent) __);
}


/// Adds pattern-matching-related methods to [JobUpdateEvent].
extension JobUpdateEventPatterns on JobUpdateEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( JobUpdateSnapshot value)?  snapshot,TResult Function( JobUpdateStatus value)?  status,TResult Function( JobUpdateMetadata value)?  metadata,TResult Function( JobUpdateTranscriptWord value)?  transcriptWord,TResult Function( JobUpdateTranscriptDone value)?  transcriptDone,TResult Function( JobUpdateSummaryWord value)?  summaryWord,TResult Function( JobUpdateSummaryDone value)?  summaryDone,TResult Function( JobUpdateDone value)?  done,TResult Function( JobUpdateError value)?  error,TResult Function( JobUpdateHeartbeat value)?  heartbeat,TResult Function( JobUpdatePong value)?  pong,required TResult orElse(),}){
final _that = this;
switch (_that) {
case JobUpdateSnapshot() when snapshot != null:
return snapshot(_that);case JobUpdateStatus() when status != null:
return status(_that);case JobUpdateMetadata() when metadata != null:
return metadata(_that);case JobUpdateTranscriptWord() when transcriptWord != null:
return transcriptWord(_that);case JobUpdateTranscriptDone() when transcriptDone != null:
return transcriptDone(_that);case JobUpdateSummaryWord() when summaryWord != null:
return summaryWord(_that);case JobUpdateSummaryDone() when summaryDone != null:
return summaryDone(_that);case JobUpdateDone() when done != null:
return done(_that);case JobUpdateError() when error != null:
return error(_that);case JobUpdateHeartbeat() when heartbeat != null:
return heartbeat(_that);case JobUpdatePong() when pong != null:
return pong(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( JobUpdateSnapshot value)  snapshot,required TResult Function( JobUpdateStatus value)  status,required TResult Function( JobUpdateMetadata value)  metadata,required TResult Function( JobUpdateTranscriptWord value)  transcriptWord,required TResult Function( JobUpdateTranscriptDone value)  transcriptDone,required TResult Function( JobUpdateSummaryWord value)  summaryWord,required TResult Function( JobUpdateSummaryDone value)  summaryDone,required TResult Function( JobUpdateDone value)  done,required TResult Function( JobUpdateError value)  error,required TResult Function( JobUpdateHeartbeat value)  heartbeat,required TResult Function( JobUpdatePong value)  pong,}){
final _that = this;
switch (_that) {
case JobUpdateSnapshot():
return snapshot(_that);case JobUpdateStatus():
return status(_that);case JobUpdateMetadata():
return metadata(_that);case JobUpdateTranscriptWord():
return transcriptWord(_that);case JobUpdateTranscriptDone():
return transcriptDone(_that);case JobUpdateSummaryWord():
return summaryWord(_that);case JobUpdateSummaryDone():
return summaryDone(_that);case JobUpdateDone():
return done(_that);case JobUpdateError():
return error(_that);case JobUpdateHeartbeat():
return heartbeat(_that);case JobUpdatePong():
return pong(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( JobUpdateSnapshot value)?  snapshot,TResult? Function( JobUpdateStatus value)?  status,TResult? Function( JobUpdateMetadata value)?  metadata,TResult? Function( JobUpdateTranscriptWord value)?  transcriptWord,TResult? Function( JobUpdateTranscriptDone value)?  transcriptDone,TResult? Function( JobUpdateSummaryWord value)?  summaryWord,TResult? Function( JobUpdateSummaryDone value)?  summaryDone,TResult? Function( JobUpdateDone value)?  done,TResult? Function( JobUpdateError value)?  error,TResult? Function( JobUpdateHeartbeat value)?  heartbeat,TResult? Function( JobUpdatePong value)?  pong,}){
final _that = this;
switch (_that) {
case JobUpdateSnapshot() when snapshot != null:
return snapshot(_that);case JobUpdateStatus() when status != null:
return status(_that);case JobUpdateMetadata() when metadata != null:
return metadata(_that);case JobUpdateTranscriptWord() when transcriptWord != null:
return transcriptWord(_that);case JobUpdateTranscriptDone() when transcriptDone != null:
return transcriptDone(_that);case JobUpdateSummaryWord() when summaryWord != null:
return summaryWord(_that);case JobUpdateSummaryDone() when summaryDone != null:
return summaryDone(_that);case JobUpdateDone() when done != null:
return done(_that);case JobUpdateError() when error != null:
return error(_that);case JobUpdateHeartbeat() when heartbeat != null:
return heartbeat(_that);case JobUpdatePong() when pong != null:
return pong(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)?  snapshot,TResult Function( int stageIndex,  int stageTotal,  double? progress,  String? status)?  status,TResult Function( Map<String, dynamic> data)?  metadata,TResult Function( int index,  String word)?  transcriptWord,TResult Function()?  transcriptDone,TResult Function( int index,  String word)?  summaryWord,TResult Function()?  summaryDone,TResult Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)?  done,TResult Function( String message,  String? code)?  error,TResult Function()?  heartbeat,TResult Function()?  pong,required TResult orElse(),}) {final _that = this;
switch (_that) {
case JobUpdateSnapshot() when snapshot != null:
return snapshot(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateStatus() when status != null:
return status(_that.stageIndex,_that.stageTotal,_that.progress,_that.status);case JobUpdateMetadata() when metadata != null:
return metadata(_that.data);case JobUpdateTranscriptWord() when transcriptWord != null:
return transcriptWord(_that.index,_that.word);case JobUpdateTranscriptDone() when transcriptDone != null:
return transcriptDone();case JobUpdateSummaryWord() when summaryWord != null:
return summaryWord(_that.index,_that.word);case JobUpdateSummaryDone() when summaryDone != null:
return summaryDone();case JobUpdateDone() when done != null:
return done(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateError() when error != null:
return error(_that.message,_that.code);case JobUpdateHeartbeat() when heartbeat != null:
return heartbeat();case JobUpdatePong() when pong != null:
return pong();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)  snapshot,required TResult Function( int stageIndex,  int stageTotal,  double? progress,  String? status)  status,required TResult Function( Map<String, dynamic> data)  metadata,required TResult Function( int index,  String word)  transcriptWord,required TResult Function()  transcriptDone,required TResult Function( int index,  String word)  summaryWord,required TResult Function()  summaryDone,required TResult Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)  done,required TResult Function( String message,  String? code)  error,required TResult Function()  heartbeat,required TResult Function()  pong,}) {final _that = this;
switch (_that) {
case JobUpdateSnapshot():
return snapshot(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateStatus():
return status(_that.stageIndex,_that.stageTotal,_that.progress,_that.status);case JobUpdateMetadata():
return metadata(_that.data);case JobUpdateTranscriptWord():
return transcriptWord(_that.index,_that.word);case JobUpdateTranscriptDone():
return transcriptDone();case JobUpdateSummaryWord():
return summaryWord(_that.index,_that.word);case JobUpdateSummaryDone():
return summaryDone();case JobUpdateDone():
return done(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateError():
return error(_that.message,_that.code);case JobUpdateHeartbeat():
return heartbeat();case JobUpdatePong():
return pong();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)?  snapshot,TResult? Function( int stageIndex,  int stageTotal,  double? progress,  String? status)?  status,TResult? Function( Map<String, dynamic> data)?  metadata,TResult? Function( int index,  String word)?  transcriptWord,TResult? Function()?  transcriptDone,TResult? Function( int index,  String word)?  summaryWord,TResult? Function()?  summaryDone,TResult? Function( JobDetailEntity job,  String? transcriptText,  String? summaryText,  List<Map<String, dynamic>>? summaryTakeaways)?  done,TResult? Function( String message,  String? code)?  error,TResult? Function()?  heartbeat,TResult? Function()?  pong,}) {final _that = this;
switch (_that) {
case JobUpdateSnapshot() when snapshot != null:
return snapshot(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateStatus() when status != null:
return status(_that.stageIndex,_that.stageTotal,_that.progress,_that.status);case JobUpdateMetadata() when metadata != null:
return metadata(_that.data);case JobUpdateTranscriptWord() when transcriptWord != null:
return transcriptWord(_that.index,_that.word);case JobUpdateTranscriptDone() when transcriptDone != null:
return transcriptDone();case JobUpdateSummaryWord() when summaryWord != null:
return summaryWord(_that.index,_that.word);case JobUpdateSummaryDone() when summaryDone != null:
return summaryDone();case JobUpdateDone() when done != null:
return done(_that.job,_that.transcriptText,_that.summaryText,_that.summaryTakeaways);case JobUpdateError() when error != null:
return error(_that.message,_that.code);case JobUpdateHeartbeat() when heartbeat != null:
return heartbeat();case JobUpdatePong() when pong != null:
return pong();case _:
  return null;

}
}

}

/// @nodoc


class JobUpdateSnapshot implements JobUpdateEvent {
  const JobUpdateSnapshot({required this.job, this.transcriptText, this.summaryText, final  List<Map<String, dynamic>>? summaryTakeaways}): _summaryTakeaways = summaryTakeaways;
  

 final  JobDetailEntity job;
 final  String? transcriptText;
 final  String? summaryText;
 final  List<Map<String, dynamic>>? _summaryTakeaways;
 List<Map<String, dynamic>>? get summaryTakeaways {
  final value = _summaryTakeaways;
  if (value == null) return null;
  if (_summaryTakeaways is EqualUnmodifiableListView) return _summaryTakeaways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateSnapshotCopyWith<JobUpdateSnapshot> get copyWith => _$JobUpdateSnapshotCopyWithImpl<JobUpdateSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateSnapshot&&(identical(other.job, job) || other.job == job)&&(identical(other.transcriptText, transcriptText) || other.transcriptText == transcriptText)&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&const DeepCollectionEquality().equals(other._summaryTakeaways, _summaryTakeaways));
}


@override
int get hashCode => Object.hash(runtimeType,job,transcriptText,summaryText,const DeepCollectionEquality().hash(_summaryTakeaways));

@override
String toString() {
  return 'JobUpdateEvent.snapshot(job: $job, transcriptText: $transcriptText, summaryText: $summaryText, summaryTakeaways: $summaryTakeaways)';
}


}

/// @nodoc
abstract mixin class $JobUpdateSnapshotCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateSnapshotCopyWith(JobUpdateSnapshot value, $Res Function(JobUpdateSnapshot) _then) = _$JobUpdateSnapshotCopyWithImpl;
@useResult
$Res call({
 JobDetailEntity job, String? transcriptText, String? summaryText, List<Map<String, dynamic>>? summaryTakeaways
});


$JobDetailEntityCopyWith<$Res> get job;

}
/// @nodoc
class _$JobUpdateSnapshotCopyWithImpl<$Res>
    implements $JobUpdateSnapshotCopyWith<$Res> {
  _$JobUpdateSnapshotCopyWithImpl(this._self, this._then);

  final JobUpdateSnapshot _self;
  final $Res Function(JobUpdateSnapshot) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? job = null,Object? transcriptText = freezed,Object? summaryText = freezed,Object? summaryTakeaways = freezed,}) {
  return _then(JobUpdateSnapshot(
job: null == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as JobDetailEntity,transcriptText: freezed == transcriptText ? _self.transcriptText : transcriptText // ignore: cast_nullable_to_non_nullable
as String?,summaryText: freezed == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String?,summaryTakeaways: freezed == summaryTakeaways ? _self._summaryTakeaways : summaryTakeaways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobDetailEntityCopyWith<$Res> get job {
  
  return $JobDetailEntityCopyWith<$Res>(_self.job, (value) {
    return _then(_self.copyWith(job: value));
  });
}
}

/// @nodoc


class JobUpdateStatus implements JobUpdateEvent {
  const JobUpdateStatus({required this.stageIndex, required this.stageTotal, this.progress, this.status});
  

 final  int stageIndex;
 final  int stageTotal;
 final  double? progress;
 final  String? status;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateStatusCopyWith<JobUpdateStatus> get copyWith => _$JobUpdateStatusCopyWithImpl<JobUpdateStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateStatus&&(identical(other.stageIndex, stageIndex) || other.stageIndex == stageIndex)&&(identical(other.stageTotal, stageTotal) || other.stageTotal == stageTotal)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,stageIndex,stageTotal,progress,status);

@override
String toString() {
  return 'JobUpdateEvent.status(stageIndex: $stageIndex, stageTotal: $stageTotal, progress: $progress, status: $status)';
}


}

/// @nodoc
abstract mixin class $JobUpdateStatusCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateStatusCopyWith(JobUpdateStatus value, $Res Function(JobUpdateStatus) _then) = _$JobUpdateStatusCopyWithImpl;
@useResult
$Res call({
 int stageIndex, int stageTotal, double? progress, String? status
});




}
/// @nodoc
class _$JobUpdateStatusCopyWithImpl<$Res>
    implements $JobUpdateStatusCopyWith<$Res> {
  _$JobUpdateStatusCopyWithImpl(this._self, this._then);

  final JobUpdateStatus _self;
  final $Res Function(JobUpdateStatus) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageIndex = null,Object? stageTotal = null,Object? progress = freezed,Object? status = freezed,}) {
  return _then(JobUpdateStatus(
stageIndex: null == stageIndex ? _self.stageIndex : stageIndex // ignore: cast_nullable_to_non_nullable
as int,stageTotal: null == stageTotal ? _self.stageTotal : stageTotal // ignore: cast_nullable_to_non_nullable
as int,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class JobUpdateMetadata implements JobUpdateEvent {
  const JobUpdateMetadata({required final  Map<String, dynamic> data}): _data = data;
  

 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateMetadataCopyWith<JobUpdateMetadata> get copyWith => _$JobUpdateMetadataCopyWithImpl<JobUpdateMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateMetadata&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'JobUpdateEvent.metadata(data: $data)';
}


}

/// @nodoc
abstract mixin class $JobUpdateMetadataCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateMetadataCopyWith(JobUpdateMetadata value, $Res Function(JobUpdateMetadata) _then) = _$JobUpdateMetadataCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class _$JobUpdateMetadataCopyWithImpl<$Res>
    implements $JobUpdateMetadataCopyWith<$Res> {
  _$JobUpdateMetadataCopyWithImpl(this._self, this._then);

  final JobUpdateMetadata _self;
  final $Res Function(JobUpdateMetadata) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(JobUpdateMetadata(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class JobUpdateTranscriptWord implements JobUpdateEvent {
  const JobUpdateTranscriptWord({required this.index, required this.word});
  

 final  int index;
 final  String word;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateTranscriptWordCopyWith<JobUpdateTranscriptWord> get copyWith => _$JobUpdateTranscriptWordCopyWithImpl<JobUpdateTranscriptWord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateTranscriptWord&&(identical(other.index, index) || other.index == index)&&(identical(other.word, word) || other.word == word));
}


@override
int get hashCode => Object.hash(runtimeType,index,word);

@override
String toString() {
  return 'JobUpdateEvent.transcriptWord(index: $index, word: $word)';
}


}

/// @nodoc
abstract mixin class $JobUpdateTranscriptWordCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateTranscriptWordCopyWith(JobUpdateTranscriptWord value, $Res Function(JobUpdateTranscriptWord) _then) = _$JobUpdateTranscriptWordCopyWithImpl;
@useResult
$Res call({
 int index, String word
});




}
/// @nodoc
class _$JobUpdateTranscriptWordCopyWithImpl<$Res>
    implements $JobUpdateTranscriptWordCopyWith<$Res> {
  _$JobUpdateTranscriptWordCopyWithImpl(this._self, this._then);

  final JobUpdateTranscriptWord _self;
  final $Res Function(JobUpdateTranscriptWord) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,Object? word = null,}) {
  return _then(JobUpdateTranscriptWord(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class JobUpdateTranscriptDone implements JobUpdateEvent {
  const JobUpdateTranscriptDone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateTranscriptDone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JobUpdateEvent.transcriptDone()';
}


}




/// @nodoc


class JobUpdateSummaryWord implements JobUpdateEvent {
  const JobUpdateSummaryWord({required this.index, required this.word});
  

 final  int index;
 final  String word;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateSummaryWordCopyWith<JobUpdateSummaryWord> get copyWith => _$JobUpdateSummaryWordCopyWithImpl<JobUpdateSummaryWord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateSummaryWord&&(identical(other.index, index) || other.index == index)&&(identical(other.word, word) || other.word == word));
}


@override
int get hashCode => Object.hash(runtimeType,index,word);

@override
String toString() {
  return 'JobUpdateEvent.summaryWord(index: $index, word: $word)';
}


}

/// @nodoc
abstract mixin class $JobUpdateSummaryWordCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateSummaryWordCopyWith(JobUpdateSummaryWord value, $Res Function(JobUpdateSummaryWord) _then) = _$JobUpdateSummaryWordCopyWithImpl;
@useResult
$Res call({
 int index, String word
});




}
/// @nodoc
class _$JobUpdateSummaryWordCopyWithImpl<$Res>
    implements $JobUpdateSummaryWordCopyWith<$Res> {
  _$JobUpdateSummaryWordCopyWithImpl(this._self, this._then);

  final JobUpdateSummaryWord _self;
  final $Res Function(JobUpdateSummaryWord) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,Object? word = null,}) {
  return _then(JobUpdateSummaryWord(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class JobUpdateSummaryDone implements JobUpdateEvent {
  const JobUpdateSummaryDone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateSummaryDone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JobUpdateEvent.summaryDone()';
}


}




/// @nodoc


class JobUpdateDone implements JobUpdateEvent {
  const JobUpdateDone({required this.job, this.transcriptText, this.summaryText, final  List<Map<String, dynamic>>? summaryTakeaways}): _summaryTakeaways = summaryTakeaways;
  

 final  JobDetailEntity job;
 final  String? transcriptText;
 final  String? summaryText;
 final  List<Map<String, dynamic>>? _summaryTakeaways;
 List<Map<String, dynamic>>? get summaryTakeaways {
  final value = _summaryTakeaways;
  if (value == null) return null;
  if (_summaryTakeaways is EqualUnmodifiableListView) return _summaryTakeaways;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateDoneCopyWith<JobUpdateDone> get copyWith => _$JobUpdateDoneCopyWithImpl<JobUpdateDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateDone&&(identical(other.job, job) || other.job == job)&&(identical(other.transcriptText, transcriptText) || other.transcriptText == transcriptText)&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&const DeepCollectionEquality().equals(other._summaryTakeaways, _summaryTakeaways));
}


@override
int get hashCode => Object.hash(runtimeType,job,transcriptText,summaryText,const DeepCollectionEquality().hash(_summaryTakeaways));

@override
String toString() {
  return 'JobUpdateEvent.done(job: $job, transcriptText: $transcriptText, summaryText: $summaryText, summaryTakeaways: $summaryTakeaways)';
}


}

/// @nodoc
abstract mixin class $JobUpdateDoneCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateDoneCopyWith(JobUpdateDone value, $Res Function(JobUpdateDone) _then) = _$JobUpdateDoneCopyWithImpl;
@useResult
$Res call({
 JobDetailEntity job, String? transcriptText, String? summaryText, List<Map<String, dynamic>>? summaryTakeaways
});


$JobDetailEntityCopyWith<$Res> get job;

}
/// @nodoc
class _$JobUpdateDoneCopyWithImpl<$Res>
    implements $JobUpdateDoneCopyWith<$Res> {
  _$JobUpdateDoneCopyWithImpl(this._self, this._then);

  final JobUpdateDone _self;
  final $Res Function(JobUpdateDone) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? job = null,Object? transcriptText = freezed,Object? summaryText = freezed,Object? summaryTakeaways = freezed,}) {
  return _then(JobUpdateDone(
job: null == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as JobDetailEntity,transcriptText: freezed == transcriptText ? _self.transcriptText : transcriptText // ignore: cast_nullable_to_non_nullable
as String?,summaryText: freezed == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String?,summaryTakeaways: freezed == summaryTakeaways ? _self._summaryTakeaways : summaryTakeaways // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobDetailEntityCopyWith<$Res> get job {
  
  return $JobDetailEntityCopyWith<$Res>(_self.job, (value) {
    return _then(_self.copyWith(job: value));
  });
}
}

/// @nodoc


class JobUpdateError implements JobUpdateEvent {
  const JobUpdateError({required this.message, this.code});
  

 final  String message;
 final  String? code;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobUpdateErrorCopyWith<JobUpdateError> get copyWith => _$JobUpdateErrorCopyWithImpl<JobUpdateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateError&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'JobUpdateEvent.error(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $JobUpdateErrorCopyWith<$Res> implements $JobUpdateEventCopyWith<$Res> {
  factory $JobUpdateErrorCopyWith(JobUpdateError value, $Res Function(JobUpdateError) _then) = _$JobUpdateErrorCopyWithImpl;
@useResult
$Res call({
 String message, String? code
});




}
/// @nodoc
class _$JobUpdateErrorCopyWithImpl<$Res>
    implements $JobUpdateErrorCopyWith<$Res> {
  _$JobUpdateErrorCopyWithImpl(this._self, this._then);

  final JobUpdateError _self;
  final $Res Function(JobUpdateError) _then;

/// Create a copy of JobUpdateEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = freezed,}) {
  return _then(JobUpdateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class JobUpdateHeartbeat implements JobUpdateEvent {
  const JobUpdateHeartbeat();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdateHeartbeat);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JobUpdateEvent.heartbeat()';
}


}




/// @nodoc


class JobUpdatePong implements JobUpdateEvent {
  const JobUpdatePong();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobUpdatePong);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JobUpdateEvent.pong()';
}


}




// dart format on
