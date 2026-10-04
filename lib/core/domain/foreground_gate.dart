import 'package:nutq/core/domain/cancellation.dart';

/// Waits until the app is on screen.
///
/// iOS does not let a backgrounded app submit GPU work, so on-device
/// summarization (Gemma on the GPU) must not start while the app is in the
/// background: its calls would fail and the job with them. A transcription
/// that finishes in the background waits here until the user returns.
abstract interface class ForegroundGate {
  /// Completes at once when the app is in the foreground, otherwise when it
  /// next comes back. Throws `CancelledException` if [cancellation] is
  /// cancelled while waiting.
  Future<void> whenInForeground(CancellationToken cancellation);
}

/// For tests and platforms where background GPU work is not an issue.
class AlwaysInForeground implements ForegroundGate {
  const AlwaysInForeground();

  @override
  Future<void> whenInForeground(CancellationToken cancellation) async =>
      cancellation.throwIfCancelled();
}
