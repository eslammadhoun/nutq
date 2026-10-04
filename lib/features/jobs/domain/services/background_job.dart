/// A request from the lock screen or Control Center's play/pause button.
enum BackgroundJobCommand { pause, resume }

/// What the job is doing, which decides what the lock screen says and whether
/// the app is kept running outside the screen.
enum BackgroundJobPhase {
  /// Extracting and transcribing: CPU work the app keeps doing in the
  /// background.
  transcribing,

  /// Writing the summary. Runs only while the app is on screen (iOS allows no
  /// GPU work in the background), so the app is not kept alive.
  summarizing,

  /// The transcript is ready but the app is in the background: the summary
  /// starts when the user opens it. Tells the user so.
  waitingForApp,
}

/// A job's presence outside the app: it keeps running while the user is
/// elsewhere and shows the progress of the whole job on the lock screen like a
/// media player, with the estimated total time as the timeline.
///
/// Every method is best-effort and never throws: failing to show progress must
/// not fail the job.
abstract interface class BackgroundJob {
  /// Play/pause presses from outside the app.
  Stream<BackgroundJobCommand> get commands;

  /// Starts presenting a job named [title], in [BackgroundJobPhase.transcribing].
  Future<void> begin({required String title});

  /// [progress] is the whole job's, 0.0 to 1.0. [estimatedTotal] is how long
  /// the whole job is expected to take, which the timeline spans; pass it
  /// whenever the estimate changes.
  Future<void> update({required double progress, Duration? estimatedTotal});

  Future<void> setPhase(BackgroundJobPhase phase);

  Future<void> setPaused(bool paused);

  /// [completed] is false for a failed or cancelled job. A completed job left
  /// in the background posts a notification that the summary is ready.
  Future<void> end({required bool completed});
}

/// For jobs and platforms with no background support: the job runs while the
/// app is open.
class NoBackgroundJob implements BackgroundJob {
  const NoBackgroundJob();

  @override
  Stream<BackgroundJobCommand> get commands => const Stream.empty();

  @override
  Future<void> begin({required String title}) async {}

  @override
  Future<void> update({required double progress, Duration? estimatedTotal}) async {}

  @override
  Future<void> setPhase(BackgroundJobPhase phase) async {}

  @override
  Future<void> setPaused(bool paused) async {}

  @override
  Future<void> end({required bool completed}) async {}
}
