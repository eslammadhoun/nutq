# Job processing

How a job goes from "user pressed Submit" to a stored summary, and how to add a
new kind of source (audio, video, YouTube).

```
NewJobCubit ──► SubmitJob ──► JobsRepository.createJob   (stored: pending)
                    │
                    └──────► JobScheduler.enqueue  ──►  JobRunner  (app-wide queue, one job at a time)
                                                            │
                                                            ▼
                                                        ProcessJob
                                            ┌───────────────┴────────────────┐
                                            ▼                                ▼
                                  TranscriptSource.resolve          SummarizeTranscript
                                (per JobSourceType; text = instant)   (clean → chunk → analyze → merge → final → validate)
                                            └───────────────┬────────────────┘
                                                            ▼
                              JobsRepository: markRunning / saveTranscript / updateSourceInfo / completeJob | failJob | cancelJob

JobDetailCubit = watchJob(id)  (durable state, from the database)
               + JobScheduler.watchLive(id)  (progress and streaming summary, in memory)
```

## Rules

- **The database is the truth for anything durable.** Screens read `watchJob` / `watchJobs`.
  Progress and the streaming summary are in-memory only (`JobLive`) and never stored.
- **Jobs outlive screens.** `JobRunner` owns processing; leaving Job Detail never stops a job.
  Only `JobScheduler.cancel` does. A screen opened mid-run gets the current progress at once.
- **One job at a time, FIFO.** Models are big and generation is serial.
- **Every outcome is recorded.** `ProcessJob` writes `completed`, `failed(reason)` or `cancelled`;
  the progress bar is monotonic across stages however a source reports it.
- **Crash recovery.** `JobRunner.start()` (after the first frame) fails jobs an earlier session
  left `pending`/`running` as `interrupted` — only jobs created before this session began.
- **Memory.** After 2 idle minutes the runner calls `SummarizationRepository.release()`, which
  unloads the model. The next job reloads it.
- **Not handled:** the OS suspending or killing the app mid-job. That needs platform background
  execution (foreground service on Android, background tasks on iOS).

## Adding a source type (audio, video, YouTube)

1. **Implement `TranscriptSource`** (`features/jobs/domain/sources/`):
   - `type`: the `JobSourceType` it handles.
   - `progressShare`: the fraction of the progress bar spent in your work (for example `0.6` for
     download + transcription; pasted text is `0`).
   - `resolve(SourceRequest)`: produce a `SourceTranscript`. Report progress with
     `request.onProgress(JobProgress(JobStage.acquiring | transcribing, fraction: 0..1))`, persist
     what you learn with `request.saveSourceInfo(SourceInfo(...))`, call
     `request.cancellation.throwIfCancelled()` between steps, and throw
     `JobFailure(JobFailureKind.sourceUnavailable | unsupportedMedia | transcriptionFailed |
     insufficientStorage)` to fail with a specific reason. Return `modelName`/`modelVersion` for ASR.
   - Put platform-specific code (downloader, ffmpeg, Whisper) behind an interface in the data layer,
     as `LlmRuntime` does for Gemma, so the logic is testable with a fake.
2. **Register it** in `_registerJobs()` (`core/di/dependency_injection.dart`):
   `TranscriptSourceRegistry(const [TextTranscriptSource(), YourSource(...)])`. That alone enables the
   type in the New Job sheet (`supportedSources`) and makes `ProcessJob` use it.
3. **Give the form its input.** `NewJobCubit` already builds the right `NewJobDraft` per type
   (`.youtube(url)`, `.media(filePath, mimeType, title)`); implement the file picker / URL field
   behind the existing stubs (`pickMedia`, `YoutubeSourceSection`) and copy picked files into app
   storage so `sourceFilePath` is app-owned (it is deleted with the job).
4. **Resource contention.** If your source loads its own large model (Whisper), unload it before
   summarization starts, or teach `JobRunner.onIdle` to release both. Two big models in memory at once
   is the failure to avoid.
5. **Tests.** Use `FakeMediaSource` (`test/features/jobs/support/`) as the pattern: registered
   sources, progress split, stored source info, failure reasons, cancellation.

Nothing else needs to change: storage (schema v2), the queue, cancellation, recovery, the Job Detail
progress card, failure messages (`JobFailureKind` has localized strings for the source failures) and
file cleanup on delete already handle non-text jobs.

## What is verified, and what is not

Unit, integration and widget tests cover the queue, the processor, the source strategy (with a fake),
storage, migrations, and the UI. **Not verified:** anything on a real device — the model, the audio
stack, background execution, and real-world speed (see `docs/summarization_benchmark.md`).
