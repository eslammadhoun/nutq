/// Where a job's input comes from.
///
/// Persisted by name and used directly by the New Job selector (declaration
/// order is the tab order). Which of these can actually be processed is decided
/// by the registered `TranscriptSource`s, not by this enum.
enum JobSourceType { text, video, audio, youtube }
