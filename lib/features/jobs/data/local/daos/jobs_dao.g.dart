// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_dao.dart';

// ignore_for_file: type=lint
mixin _$JobsDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobsTable get jobs => attachedDatabase.jobs;
  $JobTranscriptsTable get jobTranscripts => attachedDatabase.jobTranscripts;
  $JobSummariesTable get jobSummaries => attachedDatabase.jobSummaries;
  JobsDaoManager get managers => JobsDaoManager(this);
}

class JobsDaoManager {
  final _$JobsDaoMixin _db;
  JobsDaoManager(this._db);
  $$JobsTableTableManager get jobs =>
      $$JobsTableTableManager(_db.attachedDatabase, _db.jobs);
  $$JobTranscriptsTableTableManager get jobTranscripts =>
      $$JobTranscriptsTableTableManager(
        _db.attachedDatabase,
        _db.jobTranscripts,
      );
  $$JobSummariesTableTableManager get jobSummaries =>
      $$JobSummariesTableTableManager(_db.attachedDatabase, _db.jobSummaries);
}
