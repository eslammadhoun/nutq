// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_dao.dart';

// ignore_for_file: type=lint
mixin _$JobsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobsTable get jobs => attachedDatabase.jobs;
  $TranscriptsTable get transcripts => attachedDatabase.transcripts;
  $SummariesTable get summaries => attachedDatabase.summaries;
  $TakeawaysTable get takeaways => attachedDatabase.takeaways;
  JobsDaoManager get managers => JobsDaoManager(this);
}

class JobsDaoManager {
  final _$JobsDaoMixin _db;
  JobsDaoManager(this._db);
  $$JobsTableTableManager get jobs =>
      $$JobsTableTableManager(_db.attachedDatabase, _db.jobs);
  $$TranscriptsTableTableManager get transcripts =>
      $$TranscriptsTableTableManager(_db.attachedDatabase, _db.transcripts);
  $$SummariesTableTableManager get summaries =>
      $$SummariesTableTableManager(_db.attachedDatabase, _db.summaries);
  $$TakeawaysTableTableManager get takeaways =>
      $$TakeawaysTableTableManager(_db.attachedDatabase, _db.takeaways);
}
