# Current summarization architecture

Audit for TASK 01–02 of `nutq-implimentation-plan.md`.

Two states are documented: what existed **before** this change (read from git
history, commit `81220fe`), and what exists **now**.

## Before (commit `81220fe`, branch `feature/llama-summarization-pipeline`)

A single-shot pipeline on `llama_cpp_dart` (GGUF), built in `lib/core/ml/`:

| Piece | File | Behavior |
|---|---|---|
| Engine | `llm/llm_engine.dart`, `llm_engine_impl.dart` | `loadModel(path)`, `generate(prompt, {maxTokens})` → token stream, `cancel()`, `unloadModel()` on `llama_cpp_dart`'s worker isolate |
| Prompt | `llm/summarization_prompt_builder.dart` | One Gemma-chat-template prompt asking for strict JSON shaped like `Summary` |
| Parser | `llm/summary_response_parser.dart` | Tolerant JSON parse of the whole response |
| Pipeline | `orchestration/summarization_pipeline.dart` | Check model → load → build **one** prompt → generate (`maxTokens` 1024) → coalesce tokens into text batches → parse |
| Lock | `orchestration/inference_lock.dart` | Mutual exclusion between whisper.cpp and llama.cpp |
| Models | `models/llm_model_spec.dart` | Two GGUF tiers, Gemma 3 1B and 4B, downloaded over HTTP |

Findings against the plan:

- **No chunking, no hierarchy, no validation.** The whole transcript went into
  one prompt, which is exactly what the plan says a 1B model cannot be trusted
  to do (§54).
- **Different runtime and model format** (`llama_cpp_dart` + GGUF, downloaded)
  than the plan's `flutter_gemma` / LiteRT-LM + bundled `.litertlm` asset.
- The pipeline was a **stub**: never wired to the UI, never verified on a
  device (its own doc comment says so).
- Also present: Whisper ASR (`core/ml/whisper`), an HTTP/WebSocket network
  layer, a Drift database, and the Jobs data/domain layers, none of which
  summarization depended on beyond the stub's `Summary` result type.

Stop condition §51 ("conflicting summarization implementations / incompatible
Gemma API") applied, so the direction was confirmed with the user before
changing anything.

## After

Per the user's decision: all non-UI logic was removed, the runtime was swapped
to `flutter_gemma` + `flutter_gemma_litertlm`, and the plan was implemented.

Kept unchanged: theme, l10n, routing, core widgets, and every screen/widget
(splash, onboarding, home tabs, alerts, profile, jobs list/detail/new-job sheet,
models). Their Jobs/NewJob/JobDetail/Models cubits are now **inert UI-state
holders** (filters, form fields; no data source), so those screens render but
show empty/initial states.

New: `lib/features/summarization/` (feature-first clean architecture)

```
domain/
  entities/      Sentence, TranscriptChunk, ChunkAnalysis, LocalSummary, SummaryResult,
                 ValidationReport, SummarizationConfig, SummaryLength, progress/failure/cancellation
  text/          ArabicNormalizer, TranscriptCleaner, SentenceSegmenter, TokenCounter,
                 SemanticChunker, FactExtractor, EvidenceSelector
  usecases/      CleanTranscript, ChunkTranscript, SummarizeChunk, AggregateKeyFacts,
                 MergeSummaries (hierarchical, evidence-grounded), ValidateSummary,
                 SummarizeTranscript (full pipeline)
  repositories/  SummarizationRepository (interface)
data/
  datasources/   GemmaLocalDataSource (+Impl), GemmaGenerationConfig, GemmaTokenCounter
  prompts/       chunk_analysis, local_summary, merge, final_summary, prompt_version
  parsing/       ChunkAnalysisParser (tolerant)
  cache/         SummarizationCache (in-memory, file; SHA-256 keys incl. prompt version)
  repositories/  SummarizationRepositoryImpl
presentation/
  bloc/          SummarizationBloc (+ events, states)
  pages/         SummarizationPage (+ input / progress / result widgets)
benchmark/       BenchmarkFixture, SummaryEvaluation, HeuristicSummaryEvaluator,
                 BaselineSummarizer, SummarizationBenchmarkRunner
```

Entry point in the app: Profile tab → "Summarize text" → `/summarization`.
Model: `assets/models/gemma3-1b-it-q4.litertlm`, installed by
`FlutterGemma.installModel(...).fromAsset(...)`, engine registered in
`main.dart` with `FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()])`.
