/// Failures a screen can show to the user.
///
/// Cubits carry the raw value in their state and the UI localizes it at
/// display time (see `AppErrorL10n`), so no English text is ever built in
/// state-management code. Add a value here when a new kind of failure needs its
/// own message.
enum AppError {
  /// Reading or writing the on-device database failed.
  storage,

  /// A model download lost its connection or the server refused it.
  modelDownloadNetwork,

  /// The phone has no room for a model download.
  modelDownloadNoSpace,

  /// A downloaded model did not match its checksum, so it was thrown away.
  modelDownloadCorrupt,
}
