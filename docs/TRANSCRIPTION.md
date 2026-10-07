# Transcription (audio and video jobs)

On-device speech recognition, ported from `whisper_playground` (October 2026), where Moonshine was
measured against whisper.cpp and came out about 3.8× faster on an iPhone XR. **iOS and Android:**
the bridge is Swift on iOS and Kotlin + JNI on Android (see [Android](#android)). On other
platforms `SpeechRecognizer.isAvailable` is false, no media source is registered, and the New Job
sheet keeps the audio and video tabs disabled.

## Flow

```
New Job sheet ── pick (file_picker) ──► MediaFiles.import ──► job_media/<uuid>.<ext>   (owned by the job)
                                                                    │
ProcessJob ──► MediaTranscriptSource.resolve                        ▼
                 1. AudioExtractor (FFmpeg) ── 16 kHz mono WAV in Caches/extracted_audio   10% of the source bar
                 2. SpeechRecognizer (Moonshine, model = job's source language)          90%
                 3. delete the WAV; return the text, one recognized line per row
              ──► summarize
```

- **Files.** The picker's temporary copy is moved, not copied again, into Application Support
  (`PlatformMediaFiles`), which iOS never purges, and is deleted with the job. `file_picker_darwin`
  is vendored in `third_party/` with one patch (`NUTQ PATCH`): upstream copied every picked file
  a second time on the main thread, which froze the UI for seconds on a large video.
- **Languages.** Moonshine publishes one model per language, and audio run through the wrong one
  comes out as fragments of the other script. The job's source language picks the model
  (`MoonshineModel.of`): `tiny-streaming-ar` (31 MB) or `tiny-streaming-en` (43 MB).
- **Memory.** The bridge reads the WAV in chunks and retires its stream every 5 minutes of audio, so
  memory stays flat however long the file is. The model is released after every run, including a
  failed or cancelled one, so it is never in memory with Gemma.
- **Cancel.** `CancellationToken.onCancel` stops the FFmpeg session or tells the bridge to stop
  after the 20 s chunk in flight.
- **Live transcript.** The bridge feeds Moonshine 5 s of audio per pass and publishes the transcript
  so far after each one: lines it is done with (sent once, then kept) and the lines still being
  decoded (replaced every time). `MoonshineSpeechRecognizer` joins them into text, which travels
  `SourceRequest.onPartialTranscript` → `JobRunPartialTranscript` → `JobLive.partialTranscript`
  (throttled) → Job Detail. The transcript card shows the newest 8 lines, like captions, until the
  stored transcript replaces it. 5 s passes cost about 18% more transcription time than 20 s (measured
  in whisper_playground); the progress estimate learns the real speed.
- **Background.** See below.
- **Failures.** Unreadable media → `unsupportedMedia`; missing file → `sourceUnavailable`;
  recognition error → `transcriptionFailed`; disk error while extracting → `insufficientStorage`.

## Heat

An iPhone XR throttles its CPU and GPU once it gets hot, and everything slows with it: a 2 h 17 min
recording (October 2026) transcribed at rtf 0.25 overall and 0.37–0.45 per stream at
`thermal=serious`, against 0.08–0.12 in whisper_playground on a cool phone. So Nutq avoids work that
makes heat without making progress:

- **No endless animations while a job runs.** The progress card used an indeterminate spinner,
  which redrew the screen 60 times a second for the whole job; it is a static icon now.
  `job_detail_screen_test.dart` checks that a running job's screen settles between updates.
- **Fewer, larger Moonshine passes when no one is reading or the phone is hot.** The bridge picks
  each pass's size as it goes: 5 s while the app is on screen on a cool phone (live text), 20 s
  when the app is in the background or `ProcessInfo.thermalState` is `serious`/`critical`
  (about 18% less work for the same transcript). Each stream's log line says how many passes were
  relaxed: `relaxed=12/15`.
- **Streamed text at most 4 times a second.** Live transcript and summary updates are coalesced
  (`JobRunner.partialInterval`, 250 ms), since each one re-lays-out the growing text.

- **The summarizer is freed before transcription.** Gemma (579 MB) is otherwise kept for two idle
  minutes after a job, so a media job started soon after another transcribed next to it, with iOS
  compressing memory under it.
- **Each line is decoded once.** Moonshine's `decode_incomplete_lines` (on by default) re-decodes
  the phrase in progress on every pass for live captions; off, a line is decoded when complete. The
  phrase still in progress when a file ends is decoded from its own audio (`decodeTail`), so it is
  not lost, which is why whisper_playground had turned the option back on.

- **The app stays under iOS's background CPU limit.** iOS kills a background app that averages
  more than 80% of one core over a minute (`cpu_resource_fatal`); that ended a 2-hour job on an
  iPhone XR. When Nutq leaves the screen, the stream in progress retires at the next line boundary
  and the next ones run on a single-threaded transcriber that rests after each pass to average 60%
  of a core (`backgroundCpuShare`). Back on screen, the next stream returns to the thread pool. iOS
  also lowers a background app's CPU priority, so background streams are slower: rtf ~0.25 on the
  Simulator against 0.023 on screen. Log lines carry `background=1 rested=29s`.
- **Memory stays flat over long files.** Each pass runs in its own autorelease pool. The audio reads'
  buffers used to pile up until the job ended, ~10 MB per 5-minute stream (500 MB after 2 hours),
  which left no room to load the summarizer afterwards; now +1.4 MB per stream on the Simulator.

### Benchmarks (`integration_test/moonshine_benchmark_test.dart`)

64 minutes of Arabic speech, October 2026. Same words in every row (±2, recognition noise).

| Setting | iPhone XR | XR CPU time | Simulator | Simulator CPU time |
|---|---|---|---|---|
| Library default | | | 96.5 s | 364 s |
| Complete lines only, thread pool (**shipped**) | **312.6 s, rtf 0.081** | 844 s | 88.3 s | 309 s |
| Complete lines only, 1 thread | 348.4 s, rtf 0.090 | 356 s | 136.2 s | 138 s |

- On the XR the thread pool stays ~11% faster than one thread at every heat level, though it
  reaches `serious` after ~1 minute against ~4 and does 2.4× the work. Speed wins, so the pool
  stays; `singleThread` is kept for benchmarks.
- Two transcribers running at once (parallel workers on halves of a file) were the fastest on the
  Simulator, but two identical runs returned different transcripts: the library is not safe to run
  concurrently. Not used.

The log keeps `thermal=` on every stream line, so a slow run can be told apart: a climbing rtf at
`nominal` is a code problem; at `serious` it is the phone.

## Running in the background

`ios/Runner/JobBridge.swift` (ported from whisper_playground) shows a media job on the lock screen
from start to finish, and keeps it running while the user is elsewhere during transcription.

- **How.** It plays silence through a `.playback` audio session (`UIBackgroundModes: audio` in
  `Info.plist`), so iOS does not suspend the app when it leaves the screen or the phone locks.
  **Apple rejects apps that do this (App Store Review Guideline 2.5.4).** Nutq is not going to the
  App Store for now (October 2026); before it does, this has to be replaced, for example by
  `BGContinuedProcessingTask` (iOS 26+).
- **Phases** (`BackgroundJobPhase`, set by `ProcessJob`):
  - *transcribing*: kept alive; play/pause pauses Moonshine after the chunk in flight.
  - *summarizing*: iOS allows no GPU work in the background, so the silent audio is paused and
    the app is not kept alive. The lock screen keeps showing progress while the app is open.
  - *waitingForApp*: the transcript finished in the background. A notification says to open Nutq,
    and `ProcessJob` waits on a `ForegroundGate` before summarizing.
  Leaving the app *during* summarization pauses it (`SummarizeTranscript.foreground`): the section
  being written is stopped, Gemma is unloaded (~760 MB → ~250 MB, so iOS is less likely to end
  Nutq to free memory for the other app), the lock screen says to open Nutq, and the same section
  is written again on return; sections already written are kept. Switching to Snapchat mid-summary
  used to end the job: Nutq was the largest background app and was terminated without a report.
- **Interruptions.** If another app takes the audio during transcription (music, a call), iOS
  suspends Nutq soon after. The run freezes rather than failing, a notification says so, and it
  carries on when the user comes back.
- **Strings.** The bridge has none of its own. `PlatformBackgroundJob` sends the `backgroundJob*` ARB
  strings in the app's language at the start of each job; the bridge fills in `{percent}` and
  `{title}`.

## Android

The same channels (`nutq/moonshine`, `nutq/background_job`, `nutq/device`) are served by Kotlin
in `android/app/src/main/kotlin/com/nutq/nutq/`, ported from whisper_playground, so the Dart side
is shared.

- **Moonshine.** `MoonshinePlugin` + `MoonshineNative` over a small JNI layer
  (`android/app/src/main/cpp/nutq_moonshine.cpp`, built with CMake) against the native libraries of
  `ai.moonshine:moonshine-voice` (the AAR's Java side is not used). Models are copied from
  `ios/Runner/moonshine_models/` into the APK's assets at build time (`syncMoonshineModels`) and
  unpacked to app storage on first use (`ModelInstaller`). One difference from iOS:
  `decode_incomplete_lines` stays on, so there is no tail recovery pass.
- **Background.** `JobService` is a foreground service (`dataSync|mediaProcessing`, with a wake
  lock) for the length of a media job. Its notification shows the whole-job progress with Pause /
  Resume (while transcribing) and Cancel, and a "summary ready" notice is posted when the job ends
  off screen. Unlike iOS, the summary keeps running in the background (`AlwaysInForeground` gate):
  a foreground service gets full CPU, and the emulator measured 27.8 tokens/s off screen.
- **Notifications permission.** Asked when the first job starts (Android 13+). The job runs either
  way; if allowed mid-job, the progress notification appears straight away.
- **Emulators** use the CPU for Gemma (`isSimulator`): the emulated GPU writes about a token a
  second against ~20 on the CPU.
- **File picker.** Offers all audio or all video rather than an extension list, since Android maps
  `m4a` to `audio/mpeg` and would hide every `.m4a` file.

## Progress estimate

The app's progress bar and the lock screen show the same number: estimated time done ÷ estimated
total time for the whole job (`JobPlan` in `features/jobs/domain/services/job_estimate.dart`). The
lock-screen timeline is the estimated total, so its playhead moves in real time.

| Step | Estimated from |
|---|---|
| Extraction + transcription | audio length × `sourceRealTimeFactor` |
| Summary | expected output tokens ÷ `outputTokensPerSecond` (all-in: load, prefill, generation) |
| Expected output tokens | transcript words × summary ratio × `outputTokensPerWord`; before transcription, words = audio length × `spokenWordsPerSecond` |

During the summary, progress is the tokens written so far (summary words × tokens per word)
against the tokens expected, or the share of sections done if that is further.

The rates start at iPhone XR values and are re-measured after every job, each new measurement
counting half (`JobRates.afterTranscription` / `afterSummary`), and kept in SharedPreferences
(`job_rates`). The estimate sharpens as the job learns more (audio length after extraction,
transcript length after transcription); the bar never goes backwards, so a longer new estimate
holds it still for a moment and a shorter one moves it ahead.

## Native setup

| Piece | Where |
|---|---|
| Bridge (method channel `nutq/moonshine`, events on `nutq/moonshine/progress`) | `ios/Runner/MoonshineBridge.swift`, registered in `AppDelegate.swift` |
| Background and lock screen (method channel `nutq/background_job`: `begin`, `update`, `setPhase`, `setPaused`, `end`) | `ios/Runner/JobBridge.swift`, registered in `AppDelegate.swift` |
| Framework (not committed) | `third_party/moonshine/Moonshine.xcframework`, from `fetch-framework.sh`, linked by the `MoonshineVoice` pod |
| Models (not committed) | `ios/Runner/moonshine_models/`, from `fetch-model.sh`, bundled as a folder reference (and copied into the Android APK) |
| Android bridge, service and JNI | `android/app/src/main/kotlin/com/nutq/nutq/` (`MoonshinePlugin`, `JobPlugin`, `JobService`, registered in `MainActivity.kt`), `android/app/src/main/cpp/` |

The bridge logs one `[moonshine] …` line per run (load, inference, real-time factor, `covered`)
to the device console, in the same format as whisper_playground.

## Verified

- Unit tests: the source (progress, failures, cancel, cleanup), the recognizer against a mocked
  channel, WAV header parsing, the picker flow in `NewJobCubit`.
- `integration_test/media_transcription_test.dart` on the iOS Simulator (iPhone 17, iOS 26),
  October 2026: Arabic and English `say` samples transcribed almost word for word.
- Background, same Simulator: a 64-minute Arabic recording (`LONG_MEDIA`) kept transcribing from
  20% to 50% while Settings was in front, and finished in 195 s. The Simulator suspends apps less
  strictly than a phone, so the lock screen and a locked phone still need checking on a device.
- Android emulator (Pixel 7, API 36, arm64), October 2026: the device test passed (pass the
  samples as `AR_MEDIA_B64` / `EN_MEDIA_B64`, since the emulator cannot read the Mac's files), and
  a 16 s Arabic news clip went through the app end to end (picker, transcript at rtf 0.06–0.33,
  summary and takeaways, notification progress and "summary ready" notice), both on screen and
  with the app in the background.

## Not ported yet

From whisper_playground, left out of this first cut:

- **Resume after a kill.** The playground checkpoints the stable lines and resumes from that frame.
  Here an interrupted job fails as `interrupted` and is started over.
- **Android tail recovery.** Android keeps `decode_incomplete_lines` on; turning it off with a
  tail pass, as on iOS, needs more of the C API exposed through JNI.
