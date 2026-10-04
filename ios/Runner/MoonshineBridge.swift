import Flutter
import Foundation
import Moonshine
import UIKit

/// Exposes the Moonshine C API to Dart over a method channel.
///
/// Moonshine is a small model (tens of MB) aimed at on-device use. The transcript
/// struct it returns is owned by the transcriber and stays valid until the
/// next call, so it is copied out immediately and never freed here.
///
/// Transcription runs through the *streaming* API even though the input is a
/// finished file. The batch entry point is one blocking call with no callback,
/// so it can only report 0% then 100%; feeding the file in chunks gives a real
/// progress fraction. Upstream keeps this cheap: only the in-progress phrase is
/// re-decoded and the encoder emits only newly-stable frames, so the total is
/// close to the batch cost rather than quadratic.
final class MoonshineBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let channelName = "nutq/moonshine"

  /// Seconds of audio handed to the stream per iteration, used when the caller
  /// does not ask for a specific size. Each iteration triggers one analysis
  /// pass, and each pass both re-decodes the line still in progress and
  /// publishes the transcript so far — so this is the granularity of the live
  /// text as well as of the progress bar.
  ///
  /// Measured on a 194 s English clip, same transcript either way: 5 s chunks
  /// cost 18% more than 20 s and 10 s costs 9%. 5 s is the setting that makes
  /// text arrive fast enough to read as it is spoken, and the user chose that
  /// over the speed. The library's own throttle is 0.5 s and is not
  /// configurable through the C API, so going below 5 s buys nothing.
  private static let defaultChunkSeconds = 5.0
  private static let sampleRate = 16000

  /// Seconds of audio one stream handles before it is freed and a fresh one
  /// takes over. A stream holds the raw audio of every line it has produced,
  /// ~3.8 MB per minute, so this caps that at ~20 MB. Each swap re-reads the
  /// few seconds after the last finished line, which costs next to nothing.
  private static let streamRotationSeconds = 300.0

  /// Handle of the loaded transcriber, or -1 when nothing is loaded.
  private var handle: Int32 = -1
  private var loadedModelPath: String?

  /// Set while a `transcribe` call is in flight; nil otherwise.
  private var progressSink: FlutterEventSink?

  /// Highest progress reported in the current run. Only touched on the
  /// transcription queue.
  private var furthestFraction = 0.0

  /// Lines finished since the last progress event, waiting to be sent. Only
  /// touched on the transcription queue.
  private var unsentFinished: [[String: Any]] = []

  /// Relaxed and total passes of the stream that just ended, for its log line.
  /// Only touched on the transcription queue.
  private var lastStreamPasses = (relaxed: 0, total: 0)


  /// Pause and cancel requests, set from the platform thread and honoured by
  /// the chunk loop on the transcription queue.
  private let control = RunControl()

  /// Whether the app is on screen, kept current from app-state notifications
  /// so the transcription queue can read it without touching UIKit.
  private let appActive = AtomicFlag(true)

  /// Seconds per pass when no one is reading the live text (the app is not on
  /// screen) or the phone is hot. Fewer passes is less work for the same
  /// transcript: 20 s costs about 18% less than 5 s. Live text then arrives
  /// every 20 s, which nobody sees in the background anyway.
  private static let relaxedChunkSeconds = 20.0

  /// Transcription is CPU-bound and long, so it runs off the platform thread
  /// to keep the UI responsive.
  private let queue = DispatchQueue(label: "moonshine.transcribe", qos: .userInitiated)

  static func register(with registrar: FlutterPluginRegistrar) {
    // One instance serves both channels, so the method handler and the event
    // sink share the transcriber and the serial queue.
    let instance = MoonshineBridge()
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)

    let progress = FlutterEventChannel(
      name: "\(channelName)/progress",
      binaryMessenger: registrar.messenger()
    )
    progress.setStreamHandler(instance)

    let center = NotificationCenter.default
    center.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil
    ) { [weak instance] _ in instance?.appActive.set(true) }
    center.addObserver(
      forName: UIApplication.willResignActiveNotification, object: nil, queue: nil
    ) { [weak instance] _ in instance?.appActive.set(false) }
  }

  /// Frames for the next pass: [requested] while someone may be watching the
  /// text arrive on a cool phone, otherwise the relaxed size. Decided per pass,
  /// so a run speeds up its text again when the user comes back and slows its
  /// work down as soon as the phone heats up.
  private func passFrames(requested: Int) -> (frames: Int, relaxed: Bool) {
    let thermal = ProcessInfo.processInfo.thermalState
    let hot = thermal == .serious || thermal == .critical
    guard hot || !appActive.get() else { return (requested, false) }
    return (max(requested, Int(Self.relaxedChunkSeconds * Double(Self.sampleRate))), true)
  }

  // MARK: - FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    progressSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    progressSink = nil
    return nil
  }

  /// Reports the fraction of audio fed so far, together with the transcript as
  /// it currently stands, so the UI can show text arriving instead of waiting
  /// for the whole file. Events are delivered on the main thread because the
  /// sink is Dart-facing.
  ///
  /// Each event carries two lists, so its size does not grow with the file:
  ///
  /// - `finished`: lines of retired streams not sent before. They never change
  ///   again, so the receiver appends them once and keeps them.
  /// - `live`: every line of the current stream, which the receiver replaces
  ///   wholesale. A stream covers at most [streamRotationSeconds] of audio.
  ///
  /// Sending the whole transcript each time instead made a 2-hour run 45%
  /// slower per minute of audio than a 5-minute one on an iPhone XR: ~1,600
  /// events averaging ~1,400 lines, each encoded here, decoded in Dart and
  /// compared against the previous one.
  ///
  /// [checkpoint] is where a killed run could resume: every line before its
  /// `frame` is in the finished lines plus the first `stable` lines of `live`.
  private func reportProgress(
    _ fraction: Double, live: [[String: Any]], checkpoint: (frame: Int, stable: Int)? = nil
  ) {
    // A new stream re-reads a few seconds the previous one had already fed,
    // which would move the bar backwards; never report less than before.
    furthestFraction = max(furthestFraction, min(max(fraction, 0), 1))
    var event: [String: Any] = ["finished": unsentFinished, "live": live]
    if let checkpoint {
      event["checkpointFrame"] = checkpoint.frame
      event["stable"] = checkpoint.stable
    }
    unsentFinished = []
    // Without a listener the lines are dropped rather than kept: the returned
    // transcript, not these events, is the result.
    guard let sink = progressSink else { return }
    event["progress"] = furthestFraction
    DispatchQueue.main.async { sink(event) }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "version":
      result(Int(moonshine_get_version()))

    case "transcribe":
      guard let args = call.arguments as? [String: Any],
        let audioPath = args["audioPath"] as? String,
        let modelPath = args["modelPath"] as? String
      else {
        result(Self.flutterError("transcribe requires audioPath and modelPath"))
        return
      }
      let keepLoaded = (args["keepLoaded"] as? Bool) ?? false
      let modelArch = UInt32((args["modelArch"] as? Int) ?? 2)  // TINY_STREAMING
      let chunkSeconds = (args["chunkSeconds"] as? Double) ?? Self.defaultChunkSeconds
      // Non-zero when resuming a run the app was killed in the middle of.
      let startFrame = (args["startFrame"] as? Int) ?? 0

      // Reset here rather than inside the queue block so a cancel or pause
      // arriving between the two is not swallowed.
      control.reset()

      queue.async { [weak self] in
        guard let self else { return }
        do {
          let segments = try self.transcribe(
            audioPath: audioPath, modelPath: modelPath,
            modelArch: modelArch, keepLoaded: keepLoaded,
            chunkSeconds: chunkSeconds, startFrame: startFrame)
          DispatchQueue.main.async { result(segments) }
        } catch {
          DispatchQueue.main.async { result(Self.flutterError(error)) }
        }
      }

    case "cancel":
      // Only takes effect between chunks, so a run stops within one chunk.
      control.cancel()
      result(nil)

    case "pause":
      // Also between chunks: the chunk in flight finishes first.
      control.setPaused(true)
      result(nil)

    case "resume":
      control.setPaused(false)
      result(nil)

    case "release":
      releaseTranscriber()
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Transcription

  private func transcribe(
    audioPath: String, modelPath: String, modelArch: UInt32, keepLoaded: Bool,
    chunkSeconds: Double, startFrame: Int
  ) throws -> [[String: Any]] {
    // Only opens the file and parses the header; the audio itself is read as
    // the stream consumes it.
    let openStarted = DispatchTime.now().uptimeNanoseconds
    let audio = try WavStream(path: audioPath)
    let openSeconds = Self.seconds(since: openStarted)

    // Model load is broken out here because the Dart stopwatch starts before
    // the channel call and so includes it; this separates load from inference.
    let loadStarted = DispatchTime.now().uptimeNanoseconds
    let transcriber = try ensureTranscriber(modelPath: modelPath, modelArch: modelArch)
    let loadSeconds = Self.seconds(since: loadStarted)

    // Time spent paused is left out, so the figures describe the work.
    let inferStarted = DispatchTime.now().uptimeNanoseconds
    let (segments, streams) = try transcribeAsStream(
      transcriber: transcriber, audio: audio, chunkSeconds: chunkSeconds,
      startFrame: startFrame)
    let inferSeconds = Self.seconds(since: inferStarted) - control.pausedSeconds
    let pausedSeconds = control.pausedSeconds

    // Printed rather than returned so the stage breakdown lands in the device
    // console. ffmpeg and the Dart side write here too, hence the prefix.
    //
    // `covered` is the end of the last line as a fraction of the audio. A
    // transcription that stops early still looks fast and still reads well, so
    // the RTF is only meaningful alongside it. A run with lines=0 and a
    // very low RTF is audio the speech detector found nothing in, not a
    // truncated run — both are worth telling apart.
    //
    // The model name is in the line because there is one model per language,
    // so a run is only interpretable if you know which one produced it.
    let audioSeconds = Double(audio.frameCount) / Double(Self.sampleRate)
    // A resumed run only processed the audio after its starting point.
    let processedSeconds = audioSeconds - Double(startFrame) / Double(Self.sampleRate)
    let words = segments.reduce(0) { total, segment in
      let text = (segment["text"] as? String) ?? ""
      return total + text.split(separator: " ").count
    }
    let lastEnd = segments.last.map {
      ($0["start"] as? Double ?? 0) + ($0["duration"] as? Double ?? 0)
    } ?? 0
    NSLog(
      "[moonshine] model=%@ open=%.3fs load=%.3fs infer=%.3fs paused=%.1fs audio=%.1fs "
        + "from=%.1fs rtf=%.3f lines=%d words=%d covered=%.3f streams=%d thermal=%@ "
        + "footprint=%dMB",
      modelPath as NSString, openSeconds, loadSeconds, inferSeconds, pausedSeconds,
      audioSeconds, Double(startFrame) / Double(Self.sampleRate),
      processedSeconds > 0 ? inferSeconds / processedSeconds : 0, segments.count, words,
      audioSeconds > 0 ? min(lastEnd / audioSeconds, 1) : 0, streams,
      Self.thermalState() as NSString, Self.footprintMegabytes())

    if !keepLoaded {
      releaseTranscriber()
    }
    return segments
  }

  /// Feeds [audio] to the transcriber in chunks, publishing progress and the
  /// transcript so far after each pass, and returns the final transcript as
  /// plain Swift values with times measured from the start of the file.
  ///
  /// Publishing the partial transcript is the reason this uses the streaming
  /// API at all rather than the batch call: the batch entry point returns once,
  /// at the end, so the text could only ever appear all at once.
  ///
  /// A long file is split across several streams (see [streamRotationSeconds]).
  /// Each stream keeps the raw audio of every line it has produced — the
  /// `audio_data` field of `transcript_line_t` — until it is freed, and there is
  /// no option to turn that off. Fed a whole file, one stream held ~576 MB of
  /// audio for a 2.5-hour video and grew until iOS killed the app just before
  /// the end. Retiring the stream every few minutes keeps memory flat whatever
  /// the length.
  ///
  /// Pause and cancel are honoured between chunks, which is only possible
  /// because the audio is fed in pieces.
  ///
  /// A resumed run starts at [firstFrame] and returns only the lines from there
  /// on; the caller already holds the ones before it.
  private func transcribeAsStream(
    transcriber: Int32, audio: WavStream, chunkSeconds: Double, startFrame firstFrame: Int
  ) throws -> (segments: [[String: Any]], streams: Int) {
    let chunkFrames = max(1, Int(chunkSeconds * Double(Self.sampleRate)))
    var buffer = [Float](repeating: 0, count: chunkFrames)
    var finished: [[String: Any]] = []
    var startFrame = min(max(firstFrame, 0), audio.frameCount)
    var streams = 0
    furthestFraction = 0
    unsentFinished = []

    while true {
      try audio.seek(toFrame: startFrame)
      let started = DispatchTime.now().uptimeNanoseconds
      let pausedBefore = control.pausedSeconds
      let pass = try transcribeOneStream(
        transcriber: transcriber, audio: audio, startFrame: startFrame,
        chunkFrames: chunkFrames, buffer: &buffer)
      streams += 1
      finished += pass.lines
      unsentFinished += pass.lines

      // One line per stream, so a long run shows where its time went. If the
      // rtf climbs from one stream to the next, compare it with `thermal`: a
      // phone that has heated up throttles its CPU, which is not something the
      // code can fix; a climb at `nominal` is.
      let endFrame = pass.resumeFrame ?? audio.frameCount
      let streamAudio = Double(endFrame - startFrame) / Double(Self.sampleRate)
      let streamSeconds = Self.seconds(since: started) - (control.pausedSeconds - pausedBefore)
      // `relaxed` is how many of the stream's passes used the larger chunk
      // (app off screen or phone hot).
      NSLog(
        "[moonshine] stream %d audio=%.0f-%.0fs infer=%.1fs rtf=%.3f thermal=%@ relaxed=%d/%d "
          + "footprint=%dMB",
        streams, Double(startFrame) / Double(Self.sampleRate),
        Double(endFrame) / Double(Self.sampleRate), streamSeconds,
        streamAudio > 0 ? streamSeconds / streamAudio : 0, Self.thermalState() as NSString,
        lastStreamPasses.relaxed, lastStreamPasses.total, Self.footprintMegabytes())

      guard let resumeFrame = pass.resumeFrame else { break }
      startFrame = resumeFrame
    }

    // Flushes the last stream's lines, so the transcript the UI has assembled
    // from the events matches the value this call returns.
    reportProgress(1, live: [])
    return (finished, streams)
  }

  /// Runs one stream from [startFrame] until the file ends or the stream is
  /// due to be retired.
  ///
  /// When it is retired, only lines Moonshine has marked complete are kept, and
  /// [resumeFrame] is where the last of them ends: the next stream re-reads the
  /// file from there, so the phrase that was still in progress is transcribed
  /// whole rather than cut at the seam. Returns a nil [resumeFrame] at the end
  /// of the file, after draining the stream so the tail is not dropped.
  ///
  /// The lines are copied out rather than handed back as a pointer: the
  /// transcript is owned by the stream, and the stream is freed on the way out.
  /// Returning the pointer and reading it in the caller yields an empty
  /// transcript — which still looks fast and still "succeeds", so it is only
  /// visible through the `covered` figure in the log.
  private func transcribeOneStream(
    transcriber: Int32, audio: WavStream, startFrame: Int, chunkFrames: Int,
    buffer: inout [Float]
  ) throws -> (lines: [[String: Any]], resumeFrame: Int?) {
    let stream = moonshine_create_stream(transcriber, 0)
    guard stream >= 0 else {
      throw MoonshineError.failed(
        "create_stream: \(String(cString: moonshine_error_to_string(stream)))")
    }
    defer { moonshine_free_stream(transcriber, stream) }

    try check(moonshine_start_stream(transcriber, stream), "start_stream")

    let offset = Double(startFrame) / Double(Self.sampleRate)
    let rotationFrames = Int(Self.streamRotationSeconds * Double(Self.sampleRate))
    var transcriptPtr: UnsafeMutablePointer<transcript_t>?
    var fed = 0
    var relaxedPasses = 0
    var totalPasses = 0
    defer { lastStreamPasses = (relaxedPasses, totalPasses) }

    // Adding audio is cheap and buffers only; the analysis happens in
    // moonshine_transcribe_stream, which is why progress is reported per chunk
    // rather than per sample.
    while true {
      // Blocks here while paused; throws once cancelled.
      try control.checkpoint()

      let pass = passFrames(requested: chunkFrames)
      if pass.relaxed { relaxedPasses += 1 }
      totalPasses += 1
      let frames = try audio.read(maxFrames: pass.frames, into: &buffer)
      if frames == 0 { break }

      try buffer.withUnsafeBufferPointer { pointer in
        try check(
          moonshine_transcribe_add_audio_to_stream(
            transcriber, stream, pointer.baseAddress!, UInt64(frames),
            Int32(Self.sampleRate), 0),
          "add_audio_to_stream")
      }
      try check(
        moonshine_transcribe_stream(transcriber, stream, 0, &transcriptPtr),
        "transcribe_stream")
      fed += frames

      let current = transcriptPtr.map { Self.copySegments(from: $0, offset: offset) } ?? []

      // Where a killed run could pick up: the end of this stream's last
      // finished line, or the stream's start before any line has finished.
      // The same seam a stream switch uses, so no word is cut. Sent with every
      // event; the receiver saves it only when it moves.
      var checkpoint = (frame: startFrame, stable: 0)
      if let transcript = transcriptPtr, let last = Self.lastCompleteLine(in: transcript) {
        let endFrame = Int((Double(last.end) * Double(Self.sampleRate)).rounded())
        if endFrame > 0 {
          // `current` skips empty lines, so count the finished ones the same way.
          let stable = Self.copySegments(from: transcript, offset: offset, throughLine: last.index)
          checkpoint = (startFrame + endFrame, stable.count)
        }
      }
      reportProgress(
        audio.frameCount > 0 ? Double(startFrame + fed) / Double(audio.frameCount) : 1,
        live: current, checkpoint: checkpoint)

      // Retire the stream at a line boundary. If no line has completed yet —
      // one unbroken stretch of speech — keep going: that is rare, and cutting
      // mid-phrase would lose words.
      if fed >= rotationFrames, let transcript = transcriptPtr,
        let lastComplete = Self.lastCompleteLine(in: transcript)
      {
        let endFrame = Int((Double(lastComplete.end) * Double(Self.sampleRate)).rounded())
        if endFrame > 0 {
          let kept = Self.copySegments(
            from: transcript, offset: offset, throughLine: lastComplete.index)
          return (kept, startFrame + endFrame)
        }
      }
    }

    // Stopping keeps the leftover audio and lets the final call analyse it even
    // if it is shorter than the library's 0.5 s throttle, so the tail of the
    // file is not dropped.
    try check(moonshine_stop_stream(transcriber, stream), "stop_stream")
    try check(
      moonshine_transcribe_stream(transcriber, stream, 0, &transcriptPtr), "final drain")

    guard let transcript = transcriptPtr else {
      throw MoonshineError.failed("transcribe_stream returned no transcript")
    }
    // Copied out here because the `defer` above frees the stream.
    return (Self.copySegments(from: transcript, offset: offset), nil)
  }

  /// The last line Moonshine has finished with, and where it ends in seconds
  /// from the start of the stream, or nil when every line is still open.
  private static func lastCompleteLine(
    in transcript: UnsafeMutablePointer<transcript_t>
  ) -> (index: Int, end: Float)? {
    let count = Int(transcript.pointee.line_count)
    guard count > 0, let lines = transcript.pointee.lines else { return nil }
    for i in stride(from: count - 1, through: 0, by: -1) where lines[i].is_complete != 0 {
      return (i, lines[i].start_time + lines[i].duration)
    }
    return nil
  }

  /// Copies lines out of a transcript into plain Swift values, shifting their
  /// times by [offset] seconds so they count from the start of the file rather
  /// than the stream. Stops after [throughLine] when it is given. The pointer
  /// must still be owned by a live transcriber or stream when this is called.
  private static func copySegments(
    from transcript: UnsafeMutablePointer<transcript_t>, offset: Double,
    throughLine: Int? = nil
  ) -> [[String: Any]] {
    var segments: [[String: Any]] = []
    let count = min(Int(transcript.pointee.line_count), throughLine.map { $0 + 1 } ?? .max)
    guard count > 0, let lines = transcript.pointee.lines else { return segments }
    for i in 0..<count {
      let line = lines[i]
      guard let textPtr = line.text else { continue }
      let text = String(cString: textPtr).trimmingCharacters(in: .whitespacesAndNewlines)
      if text.isEmpty { continue }
      segments.append([
        "text": text,
        "start": offset + Double(line.start_time),
        "duration": Double(line.duration),
      ])
    }
    return segments
  }

  /// How hot the device is running. From `serious` up iOS throttles the CPU,
  /// which slows inference regardless of the code.
  private static func thermalState() -> String {
    switch ProcessInfo.processInfo.thermalState {
    case .nominal: return "nominal"
    case .fair: return "fair"
    case .serious: return "serious"
    case .critical: return "critical"
    @unknown default: return "unknown"
    }
  }

  /// Memory iOS counts against the app when deciding whether to kill it, in
  /// MB. Logged at each stream swap so a long run shows whether it stays flat.
  private static func footprintMegabytes() -> Int {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(
      MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
    let result = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
      }
    }
    return result == KERN_SUCCESS ? Int(info.phys_footprint / 1_048_576) : -1
  }

  private func check(_ code: Int32, _ what: String) throws {
    if code != 0 {
      throw MoonshineError.failed(
        "\(what): \(String(cString: moonshine_error_to_string(code)))")
    }
  }

  /// Loads the model if it is not already resident. The transcriber is bound
  /// to a model directory, so a different path forces a reload.
  private func ensureTranscriber(modelPath: String, modelArch: UInt32) throws -> Int32 {
    let resolved = try Self.resolveModelPath(modelPath)
    if handle >= 0, loadedModelPath == resolved {
      return handle
    }
    releaseTranscriber()

    let newHandle = Self.loadTranscriber(path: resolved, modelArch: modelArch)
    if newHandle < 0 {
      throw MoonshineError.failed(
        "load \(resolved): \(String(cString: moonshine_error_to_string(newHandle)))")
    }
    handle = newHandle
    loadedModelPath = resolved
    return newHandle
  }

  /// Loads a transcriber with the library's default options.
  ///
  /// This used to pass `decode_incomplete_lines=false`, to skip re-decoding the
  /// in-progress phrase on every one of the stream's analysis passes. The
  /// justification written here was that it "cannot change the final
  /// transcript, because every line is complete by the time we drain the
  /// stream" — which is false. With the option off, the line still in progress
  /// at the final drain is marked complete but its text is never decoded, so
  /// the last phrase of *every* file was silently dropped. Measured on a
  /// 5-minute clip: 476 words against 491 with the default. The default costs
  /// about 12% more compute and returns the whole transcript.
  ///
  /// The `MOONSHINE_FLAG_FORCE_UPDATE` flag on the final drain does not recover
  /// it, and neither does feeding trailing silence; the option governs whether
  /// the decoder runs at all.
  private static func loadTranscriber(path: String, modelArch: UInt32) -> Int32 {
    moonshine_load_transcriber_from_files(
      path, modelArch, nil, 0, Int32(MOONSHINE_HEADER_VERSION))
  }

  /// Turns a model reference into a directory on disk.
  ///
  /// Absolute paths are used as-is. A bare name is looked up inside the app
  /// bundle, first directly and then under `moonshine_models/`, which is where
  /// the bundled model folder reference lands.
  private static func resolveModelPath(_ path: String) throws -> String {
    if path.hasPrefix("/") {
      return path
    }
    let bundle = Bundle.main.resourceURL ?? Bundle.main.bundleURL
    let candidates = [
      bundle.appendingPathComponent(path),
      bundle.appendingPathComponent("moonshine_models").appendingPathComponent(path),
    ]
    for candidate in candidates {
      var isDirectory: ObjCBool = false
      if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDirectory),
        isDirectory.boolValue
      {
        return candidate.path
      }
    }
    throw MoonshineError.failed(
      "no bundled model directory for '\(path)'; looked in "
        + candidates.map(\.path).joined(separator: ", "))
  }

  private func releaseTranscriber() {
    if handle >= 0 {
      moonshine_free_transcriber(handle)
      handle = -1
      loadedModelPath = nil
    }
  }

  // MARK: - WAV reading

  /// Reads a 16-bit PCM WAV one chunk at a time.
  ///
  /// This used to load the whole file into `Data` and convert the whole thing
  /// to `[Float]`, holding both at once — 206 MiB for a 37-minute video and
  /// growing linearly with length, which is an out-of-memory risk on a 3 GB
  /// device. Reading incrementally keeps it flat: a two-hour video now costs
  /// the same as a short clip.
  ///
  /// The app's FFmpeg step always produces 16 kHz mono s16, so anything else is
  /// a bug worth surfacing rather than silently resampling.
  private final class WavStream {
    private let handle: FileHandle
    private let channels: Int
    private var bytesRemaining: Int

    /// File offset of the first audio byte.
    private let dataStart: UInt64

    /// Total frames of audio, i.e. samples per channel.
    let frameCount: Int

    deinit { try? handle.close() }

    init(path: String) throws {
      guard let handle = FileHandle(forReadingAtPath: path) else {
        throw MoonshineError.failed("cannot open WAV: \(path)")
      }
      self.handle = handle

      do {
        let riff = try Self.read(handle, count: 12)
        guard riff.prefix(4) == Data("RIFF".utf8), riff.suffix(4) == Data("WAVE".utf8) else {
          throw MoonshineError.failed("not a RIFF/WAVE file: \(path)")
        }

        var channels = 0
        var sampleRate = 0
        var bitsPerSample = 0
        var declaredDataBytes: Int?

        // Walk the chunk table, seeking past bodies we do not need. A LIST chunk
        // of metadata can be large, so skipped chunks must not be read.
        while declaredDataBytes == nil {
          let header = try Self.read(handle, count: 8)
          let id = header.prefix(4)
          let size = Int(header[4]) | Int(header[5]) << 8
            | Int(header[6]) << 16 | Int(header[7]) << 24

          if id == Data("fmt ".utf8) {
            let body = try Self.read(handle, count: min(size, 16))
            channels = Int(body[2]) | Int(body[3]) << 8
            sampleRate = Int(body[4]) | Int(body[5]) << 8
              | Int(body[6]) << 16 | Int(body[7]) << 24
            bitsPerSample = Int(body[14]) | Int(body[15]) << 8
            try Self.skip(handle, count: size - min(size, 16))
          } else if id == Data("data".utf8) {
            // The reader is now positioned at the first audio byte.
            declaredDataBytes = size
            continue
          } else {
            try Self.skip(handle, count: size)
          }
          // Chunks are word-aligned.
          if size % 2 == 1 { try Self.skip(handle, count: 1) }
        }

        guard bitsPerSample == 16 else {
          throw MoonshineError.failed("expected 16-bit PCM, got \(bitsPerSample)-bit")
        }
        guard channels == 1 || channels == 2 else {
          throw MoonshineError.failed("expected mono or stereo, got \(channels) channels")
        }
        guard sampleRate == 16000 else {
          throw MoonshineError.failed("expected 16 kHz, got \(sampleRate) Hz")
        }

        // A streamed WAV can declare a placeholder size, so trust the file
        // length when it is shorter. A partial trailing frame is dropped.
        let dataStart = try handle.offset()
        let fileEnd = try handle.seekToEnd()
        try handle.seek(toOffset: dataStart)
        let available = Int(fileEnd - dataStart)
        let usable = min(declaredDataBytes ?? available, available)
        let frameBytes = 2 * channels

        self.channels = channels
        self.dataStart = dataStart
        self.frameCount = usable / frameBytes
        self.bytesRemaining = self.frameCount * frameBytes
      } catch {
        try? handle.close()
        throw error
      }
    }

    /// Positions the next [read] at [frame], counted from the start of the
    /// audio.
    func seek(toFrame frame: Int) throws {
      let frameBytes = 2 * channels
      let target = min(max(frame, 0), frameCount)
      try handle.seek(toOffset: dataStart + UInt64(target * frameBytes))
      bytesRemaining = (frameCount - target) * frameBytes
    }

    /// Reads up to [maxFrames] frames as normalised floats into [buffer],
    /// returning how many frames were written. Zero means the audio ended.
    func read(maxFrames: Int, into buffer: inout [Float]) throws -> Int {
      let frameBytes = 2 * channels
      let wanted = min(maxFrames, bytesRemaining / frameBytes) * frameBytes
      guard wanted > 0 else { return 0 }

      guard let raw = try handle.read(upToCount: wanted), !raw.isEmpty else { return 0 }
      // A short read means the file ended early; stop rather than loop forever.
      bytesRemaining = raw.count < wanted ? 0 : bytesRemaining - raw.count

      let frames = raw.count / frameBytes
      if buffer.count < frames {
        buffer = [Float](repeating: 0, count: frames)
      }
      raw.withUnsafeBytes { bytes in
        let base = bytes.baseAddress!.assumingMemoryBound(to: Int16.self)
        if channels == 1 {
          for i in 0..<frames {
            buffer[i] = Float(Int16(littleEndian: base[i])) / 32768.0
          }
        } else {
          for i in 0..<frames {
            let left = Float(Int16(littleEndian: base[i * 2]))
            let right = Float(Int16(littleEndian: base[i * 2 + 1]))
            buffer[i] = (left + right) / 2.0 / 32768.0
          }
        }
      }
      return frames
    }

    private static func read(_ handle: FileHandle, count: Int) throws -> Data {
      guard count > 0 else { return Data() }
      guard let data = try handle.read(upToCount: count), data.count == count else {
        throw MoonshineError.failed("truncated WAV header")
      }
      return data
    }

    private static func skip(_ handle: FileHandle, count: Int) throws {
      guard count > 0 else { return }
      let current = try handle.offset()
      try handle.seek(toOffset: current + UInt64(count))
    }
  }

  private static func seconds(since startNanoseconds: UInt64) -> Double {
    Double(DispatchTime.now().uptimeNanoseconds - startNanoseconds) / 1_000_000_000
  }

  private static func flutterError(_ message: String) -> FlutterError {
    FlutterError(code: "moonshine_error", message: message, details: nil)
  }

  /// Cancellation gets its own code so Dart can tell it apart from a real
  /// failure and return to idle rather than showing an error.
  private static func flutterError(_ error: Error) -> FlutterError {
    guard let moonshine = error as? MoonshineError else {
      return FlutterError(
        code: "moonshine_error", message: error.localizedDescription, details: nil)
    }
    return FlutterError(
      code: moonshine.code, message: moonshine.errorDescription, details: nil)
  }
}

/// A Bool shared between the main thread and the transcription queue.
private final class AtomicFlag {
  private let lock = NSLock()
  private var value: Bool

  init(_ value: Bool) { self.value = value }

  func get() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return value
  }

  func set(_ newValue: Bool) {
    lock.lock()
    value = newValue
    lock.unlock()
  }
}

/// Pause and cancel requests for the run in flight.
///
/// Requests arrive on the platform thread; the chunk loop polls them on the
/// transcription queue between chunks. A pause parks the loop on a condition
/// rather than spinning, so a paused run costs no CPU.
private final class RunControl {
  private let condition = NSCondition()
  private var cancelled = false
  private var paused = false
  private var pausedTotal = 0.0

  /// Seconds the current run has spent paused, so timings can leave it out.
  var pausedSeconds: Double {
    condition.lock()
    defer { condition.unlock() }
    return pausedTotal
  }

  func reset() {
    condition.lock()
    cancelled = false
    paused = false
    pausedTotal = 0
    condition.unlock()
  }

  func cancel() {
    condition.lock()
    cancelled = true
    condition.broadcast()  // wake a paused loop so it can stop
    condition.unlock()
  }

  func setPaused(_ value: Bool) {
    condition.lock()
    paused = value
    condition.broadcast()
    condition.unlock()
  }

  /// Returns straight away unless paused, in which case it waits for resume
  /// or cancel. Throws if the run has been cancelled.
  func checkpoint() throws {
    condition.lock()
    defer { condition.unlock() }
    if paused && !cancelled {
      let started = DispatchTime.now().uptimeNanoseconds
      while paused && !cancelled { condition.wait() }
      pausedTotal += Double(DispatchTime.now().uptimeNanoseconds - started) / 1_000_000_000
    }
    if cancelled { throw MoonshineError.cancelled }
  }
}

private enum MoonshineError: LocalizedError {
  case failed(String)
  case cancelled

  var errorDescription: String? {
    switch self {
    case .failed(let message): return message
    case .cancelled: return "Transcription cancelled"
    }
  }

  var code: String {
    switch self {
    case .failed: return "moonshine_error"
    case .cancelled: return "moonshine_cancelled"
    }
  }
}
