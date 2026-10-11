import AVFoundation
import Flutter
import MediaPlayer
import UIKit
import UserNotifications

/// Keeps a transcription running when the user leaves the app, and shows it
/// the way a media player shows a song. Ported from whisper_playground.
///
/// iOS suspends an app shortly after it leaves the screen unless it is doing
/// something the system recognises, such as playing audio. While a job runs,
/// this plays silence through a `.playback` audio session (with the `audio`
/// background mode), so the app stays alive in the app switcher and with the
/// screen off, on every supported iOS version. **Apple rejects apps that do
/// this (App Store Review Guideline 2.5.4)**; Nutq is not distributed there.
///
/// Holding the audio session is also what makes Nutq the "now playing" app,
/// so the lock screen, Control Center and Dynamic Island show the job with a
/// timeline over the source file and a play/pause button that pauses the
/// transcription. The price is that starting a job stops whatever the user
/// was listening to, as any media app does.
///
/// If another app takes the audio (the user starts music, a call comes in),
/// iOS suspends Nutq soon after. The run freezes rather than failing and
/// carries on when the user comes back; a notification says so. A killed app
/// fails the job as interrupted on the next launch.
///
/// The lock screen shows the whole job, transcription and summary, against an
/// estimated total time. Only transcription is kept alive outside the app: iOS
/// allows no GPU work in the background, so while summarizing (or waiting for
/// the user to come back and summarize) the silent audio is paused and iOS may
/// suspend the app as usual.
///
/// Every user-visible string comes from Dart (`labels` in `begin`), already
/// localized, with `{percent}` and `{title}` placeholders filled in here.
final class JobBridge: NSObject {
  private static let channelName = "nutq/background_job"
  private static let pausedNotification = "transcription-paused"
  private static let finishedNotification = "transcription-finished"
  private static let doneNotification = "summary-finished"

  /// What the job is doing; mirrors `BackgroundJobPhase` in Dart.
  private enum Phase: String {
    case transcribing, summarizing, waitingForApp
  }

  /// Rate shown before there is a measured one. Non-zero so the lock screen
  /// shows the job as running (a pause button) rather than stopped; too small
  /// for the playhead to visibly move before the first real update.
  private static let placeholderRate = 0.000_001

  private let channel: FlutterMethodChannel

  private var active = false
  private var paused = false
  private var phase = Phase.transcribing
  private var title = ""
  private var labels: [String: String] = [:]
  private var durationSeconds = 0.0
  private var fraction = 0.0

  /// Seconds of source audio transcribed per second of wall time, smoothed,
  /// so the lock-screen playhead moves at the speed the job actually runs.
  private var rate = 0.0
  private var lastUpdate: (time: TimeInterval, elapsed: Double)?

  private let keepAlive = KeepAlive()
  private var commandTargets: [(MPRemoteCommand, Any)] = []

  private init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = JobBridge(channel: channel)
    // The messenger holds this closure, which holds the instance.
    channel.setMethodCallHandler { call, result in instance.handle(call, result: result) }

    let center = NotificationCenter.default
    center.addObserver(
      instance, selector: #selector(willEnterForeground),
      name: UIApplication.willEnterForegroundNotification, object: nil)
    center.addObserver(
      instance, selector: #selector(audioInterrupted(_:)),
      name: AVAudioSession.interruptionNotification, object: nil)
    center.addObserver(
      instance, selector: #selector(mediaServicesReset),
      name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
  }

  // MARK: - Channel

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "begin":
      begin(
        title: args["title"] as? String ?? "Nutq",
        labels: args["labels"] as? [String: String] ?? [:])
    case "update":
      update(
        progress: args["progress"] as? Double ?? fraction,
        duration: args["duration"] as? Double)
    case "setPhase":
      setPhase(Phase(rawValue: args["phase"] as? String ?? "") ?? phase)
    case "setPaused":
      setPaused(args["paused"] as? Bool ?? false)
    case "end":
      end(completed: args["completed"] as? Bool ?? false, notify: args["notify"] as? Bool ?? true)
    default:
      result(FlutterMethodNotImplemented)
      return
    }
    result(nil)
  }

  // MARK: - Job lifecycle

  private func begin(title: String, labels: [String: String]) {
    active = true
    paused = false
    phase = .transcribing
    self.title = title
    self.labels = labels
    durationSeconds = 0
    fraction = 0
    rate = 0
    lastUpdate = nil
    removeNotifications()
    requestNotificationPermission()
    startKeepAlive()
    enableRemoteCommands()
    publishNowPlaying()
  }

  private func update(progress: Double, duration: Double?) {
    guard active else { return }
    if let duration { durationSeconds = duration }
    fraction = min(max(progress, 0), 1)
    measureRate()
    publishNowPlaying()
  }

  private func setPhase(_ value: Phase) {
    guard active, phase != value else { return }
    phase = value
    paused = false
    lastUpdate = nil
    switch phase {
    case .transcribing:
      startKeepAlive()
    case .summarizing:
      keepAlive.pause()
      removeNotifications()
    case .waitingForApp:
      keepAlive.pause()
      if UIApplication.shared.applicationState != .active {
        post(
          id: Self.finishedNotification, title: text("readyTitle"), body: text("readyBody"))
      }
    }
    publishNowPlaying()
  }

  private func setPaused(_ value: Bool) {
    guard active, paused != value else { return }
    paused = value
    // The rate measured before a pause says nothing about the time after it.
    lastUpdate = nil
    if paused {
      // A paused job needs no CPU, so let iOS suspend the app. The lock-screen
      // play button still reaches us: iOS wakes the now-playing app for it.
      keepAlive.pause()
    } else {
      startKeepAlive()
    }
    publishNowPlaying()
  }

  /// [notify] is the Settings switch for the "Summary ready" notification.
  private func end(completed: Bool, notify: Bool) {
    guard active else { return }
    active = false
    paused = false
    disableRemoteCommands()
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    stopKeepAlive()
    removeNotifications()
    if completed && notify && UIApplication.shared.applicationState != .active {
      post(id: Self.doneNotification, title: text("doneTitle"), body: text("doneBody"))
    }
  }

  // MARK: - Keeping the app alive

  /// Starts (or restarts) the silent audio. Safe to call repeatedly.
  /// [started] runs on the main thread with whether audio is now playing.
  private func startKeepAlive(started: ((Bool) -> Void)? = nil) {
    guard active, !paused, phase == .transcribing else { return }
    keepAlive.start { playing in
      DispatchQueue.main.async { started?(playing) }
    }
  }

  private func stopKeepAlive() {
    keepAlive.stop()
  }

  @objc private func audioInterrupted(_ notification: Notification) {
    guard active,
      let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: raw)
    else { return }
    switch type {
    case .began:
      // Another app took the audio, so iOS will suspend us shortly. The run
      // freezes rather than failing; tell the user how to continue it.
      if !paused && phase == .transcribing && UIApplication.shared.applicationState != .active {
        post(
          id: Self.pausedNotification, title: text("interruptedTitle"),
          body: text("interruptedBody"))
      }
    case .ended:
      startKeepAlive { [weak self] playing in
        if playing { self?.removeNotifications() }
      }
    @unknown default:
      break
    }
  }

  @objc private func willEnterForeground() {
    guard active else { return }
    // Back in front, the run carries on by itself. Take the audio back so it
    // can keep going the next time the user leaves.
    removeNotifications()
    startKeepAlive()
    publishNowPlaying()
  }

  @objc private func mediaServicesReset() {
    // Every audio object is invalid after a reset and must be rebuilt.
    keepAlive.discardPlayer()
    guard active else { return }
    startKeepAlive()
    enableRemoteCommands()
    publishNowPlaying()
  }

  // MARK: - Now playing

  private func publishNowPlaying() {
    guard active else { return }
    let elapsed = fraction * durationSeconds
    var info: [String: Any] = [
      MPMediaItemPropertyTitle: title,
      MPMediaItemPropertyArtist: text(paused ? "paused" : phase.rawValue),
      MPMediaItemPropertyAlbumTitle: "Nutq",
      MPMediaItemPropertyPlaybackDuration: durationSeconds,
      MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
      MPNowPlayingInfoPropertyPlaybackRate: paused || phase == .waitingForApp
        ? 0.0 : max(rate, Self.placeholderRate),
      MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
      MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
    ]
    if let artwork = Self.artwork { info[MPMediaItemPropertyArtwork] = artwork }
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
  }

  /// The label [key] with its `{percent}` and `{title}` placeholders filled.
  /// The percentage is written in the app's language (`labels["locale"]`),
  /// which can differ from the phone's.
  private func text(_ key: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.locale = Locale(identifier: labels["locale"] ?? "en")
    let percent = formatter.string(from: NSNumber(value: (fraction * 100).rounded(.down) / 100)) ?? ""
    return (labels[key] ?? "")
      .replacingOccurrences(of: "{percent}", with: percent)
      .replacingOccurrences(of: "{title}", with: title)
  }

  /// Smooths the transcription speed from successive updates.
  private func measureRate() {
    let now = ProcessInfo.processInfo.systemUptime
    let elapsed = fraction * durationSeconds
    defer { lastUpdate = (now, elapsed) }
    guard !paused, let last = lastUpdate, now - last.time > 0.5, elapsed > last.elapsed else {
      return
    }
    let measured = (elapsed - last.elapsed) / (now - last.time)
    rate = rate == 0 ? measured : rate * 0.7 + measured * 0.3
  }

  /// A waveform glyph on an indigo tile.
  private static let artwork: MPMediaItemArtwork? = {
    let size = CGSize(width: 512, height: 512)
    let image = UIGraphicsImageRenderer(size: size).image { context in
      UIColor.systemIndigo.setFill()
      context.fill(CGRect(origin: .zero, size: size))
      let config = UIImage.SymbolConfiguration(pointSize: 220, weight: .semibold)
      if let glyph = UIImage(systemName: "waveform", withConfiguration: config)?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
      {
        glyph.draw(
          at: CGPoint(
            x: (size.width - glyph.size.width) / 2, y: (size.height - glyph.size.height) / 2))
      }
    }
    return MPMediaItemArtwork(boundsSize: size) { _ in image }
  }()

  // MARK: - Lock-screen controls

  private func enableRemoteCommands() {
    disableRemoteCommands()
    let commands = MPRemoteCommandCenter.shared()
    let send: (String) -> MPRemoteCommandHandlerStatus = { [weak self] action in
      guard let self, self.active else { return .noActionableNowPlayingItem }
      // Only transcription can pause; the summary runs to the end.
      guard self.phase == .transcribing else { return .commandFailed }
      self.channel.invokeMethod("command", arguments: action)
      return .success
    }
    commandTargets = [
      (commands.pauseCommand, commands.pauseCommand.addTarget { _ in send("pause") }),
      (commands.playCommand, commands.playCommand.addTarget { _ in send("resume") }),
      (
        commands.togglePlayPauseCommand,
        commands.togglePlayPauseCommand.addTarget { [weak self] _ in
          send(self?.paused == true ? "resume" : "pause")
        }
      ),
    ]
    for (command, _) in commandTargets { command.isEnabled = true }
    // Transcription cannot seek or skip, so do not offer it.
    for command in [
      commands.changePlaybackPositionCommand, commands.nextTrackCommand,
      commands.previousTrackCommand, commands.skipForwardCommand,
      commands.skipBackwardCommand, commands.seekForwardCommand,
      commands.seekBackwardCommand,
    ] {
      command.isEnabled = false
    }
  }

  private func disableRemoteCommands() {
    for (command, target) in commandTargets {
      command.removeTarget(target)
      command.isEnabled = false
    }
    commandTargets = []
  }

  // MARK: - Notifications

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, error in
      if let error { NSLog("[job] notification permission: %@", error.localizedDescription) }
    }
  }

  private func post(id: String, title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: id, content: content, trigger: nil))
  }

  private func removeNotifications() {
    let ids = [Self.pausedNotification, Self.finishedNotification, Self.doneNotification]
    let center = UNUserNotificationCenter.current()
    center.removeDeliveredNotifications(withIdentifiers: ids)
    center.removePendingNotificationRequests(withIdentifiers: ids)
  }
}

/// The silent audio that keeps the app running, and the audio session it
/// plays through.
///
/// Everything runs on one serial queue: activating a session is blocking
/// work (Apple advises against doing it on the main thread) and can take a
/// noticeable moment when it has to stop another app's audio.
private final class KeepAlive {
  private let queue = DispatchQueue(label: "nutq.keepalive", qos: .userInitiated)
  private var player: AVAudioPlayer?

  /// Activates the session and plays silence on a loop. [completion] gets
  /// whether audio is playing, on this class's queue.
  func start(completion: @escaping (Bool) -> Void) {
    queue.async { [self] in
      do {
        let session = AVAudioSession.sharedInstance()
        // `.playback` without `.mixWithOthers`: only a non-mixable session
        // makes the app the now-playing app, which is what puts the controls
        // on the lock screen.
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
        if player == nil {
          player = try AVAudioPlayer(data: Self.silence)
          player?.numberOfLoops = -1
        }
        completion(player?.play() ?? false)
      } catch {
        // The job carries on while the app is on screen; it just cannot keep
        // running in the background this time.
        NSLog("[job] could not start background audio: %@", error.localizedDescription)
        completion(false)
      }
    }
  }

  func pause() {
    queue.async { [self] in player?.pause() }
  }

  func stop() {
    queue.async { [self] in
      player?.stop()
      player = nil
      // Let the audio the user was listening to before the job pick up again.
      try? AVAudioSession.sharedInstance().setActive(
        false, options: .notifyOthersOnDeactivation)
    }
  }

  /// After a media-services reset every audio object is invalid.
  func discardPlayer() {
    queue.async { [self] in player = nil }
  }

  /// One second of 8 kHz mono 16-bit silence as a WAV file, looped forever.
  private static let silence: Data = {
    let sampleRate: UInt32 = 8000
    let dataSize = sampleRate * 2
    var data = Data()
    func append<T>(_ value: T) { withUnsafeBytes(of: value) { data.append(contentsOf: $0) } }
    data.append(contentsOf: Array("RIFF".utf8)); append(UInt32(36 + dataSize).littleEndian)
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8)); append(UInt32(16).littleEndian)
    append(UInt16(1).littleEndian)  // PCM
    append(UInt16(1).littleEndian)  // mono
    append(sampleRate.littleEndian)
    append((sampleRate * 2).littleEndian)  // byte rate
    append(UInt16(2).littleEndian)  // block align
    append(UInt16(16).littleEndian)  // bits per sample
    data.append(contentsOf: Array("data".utf8)); append(dataSize.littleEndian)
    data.append(Data(count: Int(dataSize)))
    return data
  }()
}
