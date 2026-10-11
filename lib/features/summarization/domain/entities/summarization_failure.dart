enum SummarizationFailureKind {
  emptyTranscript,
  modelUnavailable,
  generationFailed,

  /// The app was closed or killed while the job was running.
  interrupted,
}

/// A pipeline failure the UI localizes by [kind]; [message] is developer
/// detail only and is never shown to users.
class SummarizationFailure implements Exception {
  const SummarizationFailure(this.kind, [this.message = '']);

  final SummarizationFailureKind kind;
  final String message;

  @override
  String toString() => 'SummarizationFailure($kind, $message)';
}
