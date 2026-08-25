import 'dart:async';

/// Session lifecycle events broadcast app-wide.
enum SessionEvent { expired }

/// Decouples the network layer (which detects session death) from the UI
/// layer (which must react by redirecting to login).
///
/// The Dio stack cannot import widgets/routing, and the widget tree cannot
/// know when a refresh chain gives up — this bridge carries that signal.
class SessionManager {
  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get events => _controller.stream;

  void notifyExpired() {
    _controller.add(SessionEvent.expired);
  }
}
