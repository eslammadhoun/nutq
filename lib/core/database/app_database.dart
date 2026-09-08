import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nutq/core/database/daos/jobs_dao.dart';
import 'package:nutq/core/database/tables.dart';

part 'app_database.g.dart';

/// Local SQLite (drift) database backing the entirely-on-device jobs
/// feature — replaces the backend as the single source of truth for
/// job/transcript/summary/takeaway data. See `lib/core/database/tables.dart`
/// for the schema.
@DriftDatabase(tables: [Jobs, Transcripts, Summaries, Takeaways, InstalledModels], daos: [JobsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'nutq_db');
  }
}
