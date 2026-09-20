# Local storage (jobs)

Summary jobs are stored on the device in SQLite through [Drift](https://drift.simonbinder.eu/).
The database is the **single source of truth**: screens read live queries and
never hold their own copy of job data.

## Layers

```
presentation   JobsCubit · JobDetailCubit · NewJobCubit          (streams in, state out)
domain         JobsRepository (interface) · RunSummaryJob · entities · exceptions
data           JobsRepositoryImpl → JobsLocalDataSource → JobsDao → AppDatabase (Drift)
```

- `core/database/app_database.dart` assembles the tables and DAOs; each feature
  owns its own tables/DAO (`features/jobs/data/local/`).
- Drift types (rows, companions, converters) never leave the data layer.
  `data/mappers/job_mappers.dart` converts rows ⇄ domain entities.
- The domain depends on nothing but Dart: `JobEntity` (list row), `JobDetailEntity`
  (with `Transcript` and `Summary`), typed enums (`JobRunStatus`, `JobSourceType`,
  `SummaryLanguage`, `SummaryLength`, `SummarizationFailureKind`) — no raw status strings.

## Schema (version 1)

| Table | Purpose | Notes |
|---|---|---|
| `jobs` | One row per job | Light columns only, so list queries never load bodies. `preview` is denormalized for the list row. |
| `job_transcripts` | The text being summarized (1:1) | Can be large; read only by the detail screen and text search. |
| `job_summaries` | The finished summary (1:1) | Exists only when the job completed. `takeaways` is a JSON array in one column (only ever read/written as a whole). |

- Primary keys are UUID v4 strings, created by the repository.
- `job_transcripts` and `job_summaries` reference `jobs` with `ON DELETE CASCADE`;
  `PRAGMA foreign_keys = ON` is set on every connection (`beforeOpen`) because
  SQLite ignores foreign keys by default.
- Indexes: `jobs(created_at)` and `jobs(status, created_at)` back the list query.
- Timestamps are UTC, stored as ISO-8601 text (`build.yaml`), which keeps
  millisecond precision and sorts chronologically.
- Enums are stored by name (`textEnum`): **renaming an enum value needs a migration.**
- A `CHECK (word_count >= 0)` guards the transcript row.

## Lifecycle rules

`pending → running → completed | failed | cancelled` — final states are final.

- Every change is a **conditional update** (`WHERE status IN (allowed states)`) inside a
  transaction, and reports `applied | notFound | invalidState`. There is no
  read-then-write race, and a finished summary can never be overwritten by a late
  cancel/fail.
- Completing a job writes the summary row and the status **atomically**.
- Creating a job writes the job and transcript atomically.
- **Interrupted jobs:** an app kill leaves a job `pending`/`running` forever. On startup
  `recoverInterruptedJobs()` marks them `failed` with `interrupted` (`main.dart`), so
  the list is honest and nothing is silently re-run.
- **Leaving Job Detail while a job runs cancels it** (and records `cancelled`).
  `RunSummaryJob` does this itself when its event subscription is cancelled.

## Reads

- `watchJobs(JobsQuery)` — newest first (ties broken by id), filtered by status set and
  text, limited to a page. Text search matches the preview **or** the full transcript
  (`EXISTS` subquery); LIKE wildcards (`% _ \`) in user input are escaped and matched
  literally. Paging grows the `LIMIT` on a live query.
- `watchJob(id)` — one join (job + transcript + summary); emits `null` if deleted.
- Streams re-emit on any relevant write, so the list and detail screens update without
  manual refreshes.

## What is *not* stored

Live progress and the summary as it streams in are in-memory only (`JobDetailState`).
Only the final result is persisted, so token-by-token writes never hit the disk.

## Errors

The repository throws only `JobNotFoundException`, `InvalidJobTransitionException`,
`JobStorageException` (wrapping any driver error) and `ArgumentError` (blank text).
Cubits turn storage failures into `ApiError.storage()`; the UI localizes it.

## Testing

- `test/features/jobs/data/` runs the DAO and repository against a real in-memory
  SQLite (`AppDatabase.forTesting(NativeDatabase.memory())`): ordering, filters,
  search escaping, transitions, atomicity, cascades, foreign keys, live streams.
- `test/features/jobs/support/job_harness.dart` wires the real persistence and
  pipeline with a scripted model for the cubit and widget tests.

## Changing the schema

1. Edit the tables and bump `schemaVersion` in `AppDatabase`.
2. Add the step to `MigrationStrategy.onUpgrade` (Drift's `stepByStep` helper works well;
   generate it with `dart run drift_dev schema steps drift_schemas/ <output>`).
3. Dump the new schema: `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`
   and commit the new `drift_schema_vN.json`. Keep every old version so upgrades can
   be tested from real earlier schemas.
4. Re-run `dart run build_runner build`.

`drift` is pinned to the exact version of `drift_dev` (see `pubspec.yaml`): a mismatch
breaks the schema tool.

## Not done yet

- No automated migration test yet (there is only version 1).
- No retry action for failed/cancelled jobs, no retention policy or bulk clear.
- Verified only by tests and an iOS simulator build; not exercised on a device.
