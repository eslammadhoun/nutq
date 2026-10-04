/// Failures a screen can show to the user.
///
/// Cubits carry the raw value in their state and the UI localizes it at
/// display time (see `AppErrorL10n`), so no English text is ever built in
/// state-management code. Add a value here when a new kind of failure needs its
/// own message.
enum AppError {
  /// Reading or writing the on-device database failed.
  storage,
}
