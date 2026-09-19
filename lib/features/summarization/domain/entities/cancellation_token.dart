/// Thrown when a summarization job is cancelled.
class SummarizationCancelledException implements Exception {
  const SummarizationCancelledException();

  @override
  String toString() => 'SummarizationCancelledException';
}

/// Cooperative cancellation: the pipeline checks it between model calls and
/// stops scheduling new chunks once cancelled.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const SummarizationCancelledException();
  }
}
