/// Thrown when a long-running operation is cancelled.
class CancelledException implements Exception {
  const CancelledException();

  @override
  String toString() => 'CancelledException';
}

/// Cooperative cancellation: long-running work checks it between steps (for
/// example between model calls) and stops scheduling more once cancelled.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const CancelledException();
  }
}
