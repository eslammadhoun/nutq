/// A request from the lock screen or Control Center's play/pause button.
enum BackgroundJobCommand { pause, resume }

/// A transcription's presence outside the app: it keeps running while the
/// user is elsewhere and shows its progress on the lock screen like a media
/// player.
///
/// Every method is best-effort and never throws: failing to show progress must
/// not fail the transcription.
abstract interface class BackgroundJob {
  /// Play/pause presses from outside the app.
  Stream<BackgroundJobCommand> get commands;

  /// Starts presenting a job named [title]. [duration] is the length of the
  /// source audio, which the lock-screen timeline spans; pass it to [update]
  /// instead if it is not known yet.
  Future<void> begin({required String title, Duration? duration});

  /// [progress] runs from 0.0 to 1.0.
  Future<void> update({required double progress, Duration? duration});

  Future<void> setPaused(bool paused);

  /// [completed] is false for a failed or cancelled job. A completed job left
  /// in the background posts a notification that the transcript is ready.
  Future<void> end({required bool completed});
}

/// For platforms with no background support: the job runs while the app is
/// open.
class NoBackgroundJob implements BackgroundJob {
  const NoBackgroundJob();

  @override
  Stream<BackgroundJobCommand> get commands => const Stream.empty();

  @override
  Future<void> begin({required String title, Duration? duration}) async {}

  @override
  Future<void> update({required double progress, Duration? duration}) async {}

  @override
  Future<void> setPaused(bool paused) async {}

  @override
  Future<void> end({required bool completed}) async {}
}
