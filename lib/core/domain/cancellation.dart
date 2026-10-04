/// Thrown when a long-running operation is cancelled.
class CancelledException implements Exception {
  const CancelledException();

  @override
  String toString() => 'CancelledException';
}

/// Cooperative cancellation: long-running work checks it between steps (for
/// example between model calls) and stops scheduling more once cancelled.
///
/// Work that runs outside Dart (FFmpeg, native speech recognition) cannot poll,
/// so it registers [onCancel] to be told.
class CancellationToken {
  bool _cancelled = false;
  final _listeners = <void Function()>[];

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  void throwIfCancelled() {
    if (_cancelled) throw const CancelledException();
  }

  /// Calls [listener] once when [cancel] is called, or right away if it
  /// already was. Returns a function that unregisters it.
  void Function() onCancel(void Function() listener) {
    if (_cancelled) {
      listener();
      return () {};
    }
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }
}
