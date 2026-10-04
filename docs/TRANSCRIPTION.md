# Transcription (audio and video jobs)

On-device speech recognition, ported from `whisper_playground` (October 2026), where Moonshine was
measured against whisper.cpp and came out about 3.8× faster on an iPhone XR. **iOS only:** the
Moonshine bridge is Swift. On other platforms `SpeechRecognizer.isAvailable` is false, no media
source is registered, and the New Job sheet keeps the audio and video tabs disabled.

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
  Leaving the app *during* summarization is not handled: the app is suspended (or a GPU call fails)
  as for a pasted-text job.
- **Interruptions.** If another app takes the audio during transcription (music, a call), iOS
  suspends Nutq soon after. The run freezes rather than failing, a notification says so, and it
  carries on when the user comes back.
- **Strings.** The bridge has none of its own. `IosBackgroundJob` sends the `backgroundJob*` ARB
  strings in the app's language at the start of each job; the bridge fills in `{percent}` and
  `{title}`.

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
| Models (not committed) | `ios/Runner/moonshine_models/`, from `fetch-model.sh`, bundled as a folder reference |

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

## Not ported yet

From whisper_playground, left out of this first cut:

- **Resume after a kill.** The playground checkpoints the stable lines and resumes from that frame.
  Here an interrupted job fails as `interrupted` and is started over.
- **Android.** No Moonshine bridge yet (the playground's Android work is still in progress).
