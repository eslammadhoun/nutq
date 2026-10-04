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
- **Background.** See below.
- **Failures.** Unreadable media → `unsupportedMedia`; missing file → `sourceUnavailable`;
  recognition error → `transcriptionFailed`; disk error while extracting → `insufficientStorage`.

## Running in the background

`ios/Runner/JobBridge.swift` (ported from whisper_playground) keeps a media job alive while the user
is elsewhere, from extraction to the end of transcription:

- **How.** It plays silence through a `.playback` audio session (`UIBackgroundModes: audio` in
  `Info.plist`), so iOS does not suspend the app when it leaves the screen or the phone locks.
  **Apple rejects apps that do this (App Store Review Guideline 2.5.4).** Before an App Store
  release this has to be replaced, for example by `BGContinuedProcessingTask` (iOS 26+), which
  exists for exactly this kind of user-started long task.
- **Lock screen.** Holding the audio session makes Nutq the "now playing" app: the lock screen,
  Control Center and Dynamic Island show the file name, a timeline over the audio and play/pause,
  which pauses Moonshine after the chunk in flight. Starting a job stops whatever the user was
  listening to, as any media app does.
- **Interruptions.** If another app takes the audio (music, a call), iOS suspends Nutq soon after.
  The run freezes rather than failing, a notification says so, and it carries on when the user
  comes back.
- **Strings.** The bridge has none of its own. `IosBackgroundJob` sends the `backgroundJob*` ARB
  strings in the app's language at the start of each job; the bridge fills in `{percent}` and
  `{title}`.
- **Summarizing waits for the app.** iOS does not let a backgrounded app submit GPU work, so
  `ProcessJob` waits on a `ForegroundGate` before summarizing. A transcription that finishes in the
  background posts "Transcript ready, open Nutq to summarize", and the summary starts when the user
  returns. Leaving the app *during* summarization is not handled: the app is suspended (or a GPU
  call fails) as before this change.

## Native setup

| Piece | Where |
|---|---|
| Bridge (method channel `nutq/moonshine`, events on `nutq/moonshine/progress`) | `ios/Runner/MoonshineBridge.swift`, registered in `AppDelegate.swift` |
| Background and lock screen (method channel `nutq/background_job`) | `ios/Runner/JobBridge.swift`, registered in `AppDelegate.swift` |
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
- **Live transcript.** The bridge streams partial lines; Job Detail shows only progress.
- **Android.** No Moonshine bridge yet (the playground's Android work is still in progress).
