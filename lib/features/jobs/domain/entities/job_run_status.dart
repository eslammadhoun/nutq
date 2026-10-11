/// Lifecycle of a summary job.
///
/// `pending → running → completed | failed | cancelled`. Persisted by name, so
/// renaming a value requires a database migration.
enum JobRunStatus {
  /// Saved, not started yet.
  pending,

  /// The pipeline is working on it.
  running,
  completed,
  failed,
  cancelled;

  /// Still expected to change (used to spot jobs interrupted by an app kill).
  bool get isActive => this == pending || this == running;

  bool get isTerminal => !isActive;
}
