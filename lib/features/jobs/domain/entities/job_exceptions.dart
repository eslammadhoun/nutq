/// The job does not exist (never created, or already deleted).
class JobNotFoundException implements Exception {
  const JobNotFoundException(this.jobId);

  final String jobId;

  @override
  String toString() => 'JobNotFoundException($jobId)';
}

/// The requested lifecycle change is not allowed from the job's current state
/// (for example completing a job that is already cancelled).
class InvalidJobTransitionException implements Exception {
  const InvalidJobTransitionException(this.jobId, this.message);

  final String jobId;
  final String message;

  @override
  String toString() => 'InvalidJobTransitionException($jobId): $message';
}

/// The local database failed. [cause] carries the underlying error for logs;
/// it is never shown to users.
class JobStorageException implements Exception {
  const JobStorageException(this.cause);

  final Object cause;

  @override
  String toString() => 'JobStorageException($cause)';
}
