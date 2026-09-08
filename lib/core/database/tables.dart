import 'package:drift/drift.dart';

/// Jobs table — one row per submitted transcription job.
///
/// Replaces the backend's REST job resource. `sourceFilePath` holds the
/// permanent on-device copy of an uploaded file (the picker's cache path is
/// never stored directly — see `JobsRepositoryImpl.submitJob`). `sourceUrl`
/// is schema-only for now: URL/YouTube jobs persist the row like any other
/// but the actual online fetch is a later workstream. `inlineText` holds the
/// raw text body for `sourceType: text` jobs — simpler than modelling a
/// pre-filled Transcript row for content that was never "transcribed".
@DataClassName('JobRow')
class Jobs extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get sourceType => text()();
  TextColumn get language => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorDetail => text().nullable()();
  TextColumn get contentType => text().nullable()();
  TextColumn get previewText => text().nullable()();
  TextColumn get sourceFilePath => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get inlineText => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One-to-one with [Jobs] — a completed job's transcript body.
@DataClassName('TranscriptRow')
class Transcripts extends Table {
  TextColumn get jobId =>
      text().references(Jobs, #id, onDelete: KeyAction.cascade)();
  TextColumn get language => text()();
  IntColumn get wordCount => integer().nullable()();
  RealColumn get durationSeconds => real().nullable()();
  TextColumn get modelName => text()();
  TextColumn get modelVersion => text()();
  TextColumn get quantization => text().nullable()();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {jobId};
}

/// One-to-one with [Jobs] — a completed job's summary. Takeaways are
/// normalized into [Takeaways] rather than stored as a JSON blob column,
/// since they're genuinely relational (many ordered rows per summary).
@DataClassName('SummaryRow')
class Summaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get jobId =>
      text().references(Jobs, #id, onDelete: KeyAction.cascade).unique()();
  TextColumn get summaryText => text()();
  TextColumn get toneAndFormat => text()();
  TextColumn get modelName => text()();
  TextColumn get promptVersion => text()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
}

/// Many-to-one with [Summaries] — one row per takeaway bullet, ordered by
/// [sortOrder]. Replaces the old `List<Map<String, dynamic>>` wire shape.
@DataClassName('TakeawayRow')
class Takeaways extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get summaryId =>
      integer().references(Summaries, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  IntColumn get sortOrder => integer()();
}

/// Locally-downloaded ASR/LLM model tracking. Schema only for this
/// workstream — populated by a future model-download workstream.
@DataClassName('InstalledModelRow')
class InstalledModels extends Table {
  TextColumn get modelId => text()();
  TextColumn get kind => text()();
  TextColumn get tier => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get downloadedAt => dateTime()();
  IntColumn get sizeBytes => integer()();
  TextColumn get checksum => text()();

  @override
  Set<Column> get primaryKey => {modelId};
}
