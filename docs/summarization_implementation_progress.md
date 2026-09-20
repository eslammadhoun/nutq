# Summarization implementation progress

Tracks the 28 tasks of `nutq-implimentation-plan.md` §49.
**Status legend:** done = implemented and covered by passing tests;
partial = implemented, part deferred; blocked = needs a physical device or human input.

| # | Task | Status | Notes |
|---|---|---|---|
| 01 | Audit existing code | done | Read from git history; see `current_summarization_architecture.md` |
| 02 | Document architecture | done | Same doc |
| 03 | Benchmark fixture infrastructure | partial | 9 fixtures (3/3/3), loader, validation tests. **References are Claude drafts, "long" is ~300 words** — see `test/summarization/fixtures/README.md` |
| 04 | Baseline benchmark | partial | `BaselineSummarizer` + tests done. **No real-model baseline numbers** (needs device) |
| 05 | Evaluation structures | done | `SummaryEvaluation`, `HeuristicSummaryEvaluator` (proxy scores; coherence needs humans), `SummarizationBenchmarkResult` |
| 06 | Transcript cleaner | done | Conservative; discourse words, numbers, English, code-like tokens preserved |
| 07 | Sentence segmentation | done | Arabic punctuation, abbreviations, list markers, run-on splitting |
| 08 | Tokenizer-aware chunking | done | `SemanticChunker` + `GemmaTokenCounter` (model tokenizer via `sizeInTokens`, approximate fallback). Real tokenizer path untested off-device |
| 09 | Benchmark chunk sizes | blocked | Sweep generators exist (`BenchmarkConfiguration.chunkSizeSweep`); needs device run |
| 10 | Gemma local data source | done | Config, activation, retry once, cancellation, response cleanup. Talks to `flutter_gemma`; **not exercised against the real model** |
| 11 | Chunk analysis | done | Prompt + tolerant parser |
| 12 | Local chunk summarization | done | Failed chunks recorded (`failedChunkCount`), text kept as fallback evidence |
| 13 | Benchmark local prompts | blocked | Needs device |
| 14 | Global fact aggregation | done | Exact-duplicate dedupe only |
| 15 | Hierarchical merge | done | Pairwise, repeated until ≤ `maxSummariesBeforeFinal` |
| 16 | Context-aware merge | done | Facts + bounded source excerpts per merge; prompt shed to fit context |
| 17 | Final synthesis | done | short / medium / detailed |
| 18 | Heuristic factuality validation | done | Numbers, dates, terms, entities, claim support; flags, never rejects |
| 19 | Complete pipeline use case | done | `SummarizeTranscript` |
| 20 | BLoC integration | done | `SummarizationBloc` |
| 21 | UI progress | done | Stage names + processed/total chunks, no technical terms |
| 22 | Cancellation | done | Cooperative token + `stopGeneration()`; tested with fakes |
| 23 | Caching | done | SHA-256 incl. model + prompt version. Not wired into the app by default (dev only) |
| 24 | Quality benchmark | blocked | Needs device + human ratings |
| 25 | Performance benchmark | blocked | Needs iPhone / Android device |
| 26 | Optimize | blocked | Depends on 24–25 |
| 27 | Full regression | done | `flutter analyze --fatal-infos` clean, `flutter test` green |
| 28 | Final implementation report | partial | This file + `summarization_benchmark.md` (unanswered questions listed) |

## Deviations from the plan

- **`FinalSummaryGenerator`** is a repository method (`generateFinalSummary`) rather than its own class.
- **`data/models/*`** (JSON models) were not created: nothing is serialized except the dev cache, which stores raw text.
- **`validation_prompt.dart`** was not created: validation is deterministic (plan §26).
- **Final-summary streaming** is implemented (`generate(onPartial:)` over `getResponseAsync`, throttled in `JobDetailCubit`); only the final synthesis streams, internal stages stay hidden per plan §38. **Unverified on a device**: whether `flutter_gemma`'s `.litertlm` stream yields clean token deltas is untested, and a retry mid-stream restarts the partial text.
- **Output language** follows the New Job language toggle (`SummaryLanguage`, threaded through every prompt). Only English and Arabic; English transcripts have not been evaluated with a real model, and the benchmark fixtures are Arabic only.
- **Jobs screens integration is partial:** New Job (pasted text only) → Job Detail runs the pipeline and shows live progress via `SummarizeTranscript.stream`. The Jobs list still has no data source, so submitted jobs are not saved or listed; audio/video/YouTube sources are unavailable (no on-device transcription). The standalone page is still reachable from Profile → Summarize text.
- `GemmaGenerationConfig` exposes `maxOutputTokens` and `contextTokens` separately, because `flutter_gemma`'s `maxTokens` is the context window, not the reply length.

## Native/platform changes

- iOS Xcode project deployment target 13.0 → 15.0 (required by `flutter_gemma_litertlm`; `Podfile` already says 16.0).
- Removed the `llama_cpp_dart` notes from `android/app/build.gradle.kts` and deleted `ios/README_llama_cpp_dart.md`.
- The ~584 MB model is declared as a Flutter asset per the plan. Bundling it inflates the app and the installer copies it to app storage on first use; see the benchmark doc for the trade-off. `assets/models/` is untracked — do not commit the model binaries.
