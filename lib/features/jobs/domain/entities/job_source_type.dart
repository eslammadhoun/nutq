/// Where a job's input came from. Only [text] can be processed on-device
/// today; the others are reserved for transcription support.
enum JobSourceType { upload, youtube, url, text }
