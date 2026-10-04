/// Why a job failed. Persisted by name and localized by the UI.
///
/// Adding a value needs no migration; renaming or removing one does.
enum JobFailureKind {
  /// The transcript had no text to summarize.
  emptyTranscript,

  /// The on-device model could not be loaded.
  modelUnavailable,

  /// The model failed while generating.
  generationFailed,

  /// The app was closed or killed while the job was running.
  interrupted,

  /// The source could not be fetched (offline, removed, blocked).
  sourceUnavailable,

  /// The media is in a format that cannot be read.
  unsupportedMedia,

  /// Transcribing the audio failed.
  transcriptionFailed,

  /// Not enough free space to store or process the source.
  insufficientStorage,
}

/// Thrown by a source (or any stage) to fail a job with a specific reason.
/// [message] is developer detail only and is never shown to users.
class JobFailure implements Exception {
  const JobFailure(this.kind, [this.message = '']);

  final JobFailureKind kind;
  final String message;

  @override
  String toString() => 'JobFailure($kind, $message)';
}
