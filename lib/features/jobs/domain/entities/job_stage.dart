/// The step a running job is in. Shared by every source type: a job first
/// gets its transcript (`acquiring`, `transcribing`), then summarizes it.
enum JobStage {
  preparing,

  /// Fetching or extracting the source (download, audio extraction).
  acquiring,

  /// Turning audio into text.
  transcribing,
  analyzing,
  summarizing,
  combining,
  checking,
  finalizing,
  completed,
}
