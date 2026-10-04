# Nutq — On-Device Arabic Summarization Implementation Plan

> **Superseded (October 2026).** This was the original plan. The chunk → merge → validate pipeline
> it describes was replaced by the pipeline ported from `gemma_playground`, and the app now uses the
> fine-tuned `gemma3-1b-arabic-summarizer-v3` model instead of stock Gemma 3 1B IT. The benchmark and
> progress docs named below were removed. For the current design, see
> `docs/current_summarization_architecture.md`.

## 0. Mission

Implement and integrate a production-oriented, on-device Arabic summarization pipeline for the Nutq Flutter application using:

* Model: `Gemma3-1B-IT-q4.litertlm`
* Runtime: `flutter_gemma` / LiteRT-LM
* Platform: iOS + Android
* Offline-first
* Arabic-first
* Feature-first Clean Architecture
* BLoC/Cubit
* No server-side LLM
* No cloud API for summarization

The primary objective is **summary quality**, not maximum generation speed.

The system must summarize long Arabic transcripts while preserving:

* Main ideas
* Important facts
* Numbers
* Dates
* Names
* Technical terms
* Cause/effect relationships
* Important conclusions

It must minimize:

* Hallucinations
* Unsupported claims
* Repetition
* Loss of important information
* Meaning changes
* Excessive verbosity

---

# 1. Critical Engineering Rules

Claude Code MUST follow these rules.

## 1.1 Do not blindly implement everything at once

Implement the system incrementally.

Required order:

1. Inspect existing project
2. Establish baseline
3. Build benchmark/evaluation infrastructure
4. Implement preprocessing
5. Implement chunking
6. Implement local summarization
7. Implement hierarchical merging
8. Implement final synthesis
9. Implement validation
10. Optimize performance
11. Integrate with UI
12. Run regression tests

Do not skip directly to the final architecture.

---

## 1.2 Preserve existing functionality

Before changing anything:

* Inspect the current Nutq project.
* Identify the existing Gemma service.
* Identify current summarization flow.
* Identify current BLoC/Cubit.
* Identify current transcript models.
* Identify existing localization/theme/navigation code.
* Identify existing assets and model installation logic.

Do NOT rewrite unrelated features.

Do NOT replace working architecture unnecessarily.

Do NOT migrate state management.

Do NOT introduce Riverpod.

Do NOT introduce a backend.

Do NOT introduce another LLM.

---

# 2. Existing Model

The application must use exactly:

```text
assets/models/gemma3-1b-it-q4.litertlm
```

Model:

```text
Gemma 3 1B IT Q4
```

Do not replace it with:

* Gemma 4
* Gemma 3 4B
* Qwen
* Llama
* Cloud LLM
* OpenAI API
* Gemini API

The purpose of this implementation is specifically to optimize the summarization pipeline around the 1B on-device model.

---

# 3. Target Architecture

The final architecture should conceptually be:

```text
Audio
  ↓
ASR
  ↓
Raw Transcript
  ↓
Transcript Cleaner
  ↓
Sentence Segmentation
  ↓
Semantic/Structure-Aware Chunker
  ↓
┌───────────────────────────────────────┐
│ Chunk 1 → Gemma → Local Information   │
│ Chunk 2 → Gemma → Local Information   │
│ Chunk 3 → Gemma → Local Information   │
│ ...                                   │
│ Chunk N → Gemma → Local Information   │
└───────────────────────────────────────┘
  ↓
Local Summaries
  ↓
Global Key Facts
  ↓
Context-Aware Hierarchical Merge
  ↓
Final Synthesis
  ↓
Factuality / Consistency Validation
  ↓
Final Arabic Summary
  ↓
UI
```

---

# 4. Feature Architecture

Use feature-first Clean Architecture.

Target structure:

```text
lib/
└── features/
    └── summarization/
        ├── data/
        │   ├── datasources/
        │   │   └── gemma_local_datasource.dart
        │   │
        │   ├── models/
        │   │   ├── transcript_chunk_model.dart
        │   │   ├── chunk_analysis_model.dart
        │   │   ├── local_summary_model.dart
        │   │   └── summary_result_model.dart
        │   │
        │   └── repositories/
        │       └── summarization_repository_impl.dart
        │
        ├── domain/
        │   ├── entities/
        │   │   ├── transcript_chunk.dart
        │   │   ├── chunk_analysis.dart
        │   │   ├── local_summary.dart
        │   │   └── summary_result.dart
        │   │
        │   ├── repositories/
        │   │   └── summarization_repository.dart
        │   │
        │   └── usecases/
        │       ├── clean_transcript.dart
        │       ├── chunk_transcript.dart
        │       ├── summarize_chunk.dart
        │       ├── merge_summaries.dart
        │       ├── validate_summary.dart
        │       └── summarize_transcript.dart
        │
        └── presentation/
            ├── bloc/
            │   ├── summarization_bloc.dart
            │   ├── summarization_event.dart
            │   └── summarization_state.dart
            │
            └── pages/
```

Adapt paths if the existing project uses a slightly different feature-first structure, but preserve the same separation of responsibilities.

---

# 5. Phase 0 — Existing Project Audit

Before writing code, inspect:

```text
pubspec.yaml
lib/
assets/
ios/
android/
```

Find:

* Existing `Gemma` service
* `FlutterGemma.initialize`
* `LiteRtLmEngine`
* Model installation
* Model activation
* Current summarization code
* Current transcript source
* Existing BLoC/Cubit
* Existing dependency injection
* Existing tests

Search for:

```text
FlutterGemma
LiteRtLmEngine
Gemma
summar
transcript
getResponseAsync
getResponse
ModelType
ModelFileType
```

Document the current implementation in:

```text
docs/current_summarization_architecture.md
```

Do not modify functionality during this audit.

---

# 6. Phase 1 — Baseline

Before implementing the advanced pipeline, create a baseline summarizer.

Baseline:

```text
Transcript
    ↓
Simple chunking
    ↓
Gemma 3 1B
    ↓
Summary
```

The baseline must be measurable.

Create:

```text
test/
└── summarization/
    ├── baseline/
    └── fixtures/
```

Create benchmark fixtures containing Arabic transcripts.

Minimum:

```text
3 short
3 medium
3 long
```

Preferred final dataset:

```text
10 short
10 medium
10 long
```

Categories should include:

* Modern Standard Arabic
* Arabic conversational language
* Palestinian/Levantine-style speech where possible
* Technical content
* Educational lectures
* Numbers and dates
* English technical terms
* Repetition
* Long-context dependencies

---

# 7. Benchmark Fixture Format

Use a simple format.

Example:

```json
{
  "id": "lecture_001",
  "title": "Artificial Intelligence Lecture",
  "language": "ar",
  "duration_minutes": 30,
  "transcript": "...",
  "reference_summary": "...",
  "important_facts": [
    "...",
    "...",
    "..."
  ],
  "important_entities": [
    "...",
    "..."
  ],
  "important_numbers": [
    "...",
    "..."
  ]
}
```

Reference summaries should be human-written.

Do not generate reference summaries using Gemma.

---

# 8. Phase 2 — Evaluation Infrastructure

Create a reusable evaluation model:

```text
SummaryEvaluation
```

Metrics:

```text
coverage
faithfulness
factuality
coherence
conciseness
redundancy
arabicQuality
```

Each should initially support:

```text
0.0 → 5.0
```

Also record:

```text
inputTokens
outputTokens
processingTimeMs
tokensPerSecond
chunkCount
```

Create:

```text
SummarizationBenchmarkResult
```

with:

```text
configuration
metrics
runtime
errors
```

---

# 9. Phase 3 — Transcript Cleaning

Implement:

```text
TranscriptCleaner
```

Responsibilities:

* Normalize whitespace
* Normalize repeated punctuation
* Remove obvious ASR noise
* Reduce meaningless filler repetitions
* Preserve meaningful Arabic words
* Preserve numbers
* Preserve dates
* Preserve names
* Preserve technical terms
* Preserve English words
* Preserve code-like content
* Preserve sentence boundaries where possible

Do NOT aggressively remove:

```text
يعني
طيب
لكن
لذلك
بالتالي
```

because they may carry discourse meaning.

Cleaning must be conservative.

---

# 10. Phase 4 — Sentence Segmentation

Implement:

```text
SentenceSegmenter
```

Input:

```text
String transcript
```

Output:

```text
List<Sentence>
```

Handle Arabic punctuation:

```text
.
؟
!
،
؛
:
```

Also handle line breaks.

Do not assume every period represents a semantic boundary.

---

# 11. Phase 5 — Chunking

Implement:

```text
SemanticChunker
```

Initial configuration:

```text
targetTokens = 400
overlapTokens = 50
minTokens = 250
maxTokens = 600
```

These values are experimental defaults.

Do not treat them as final.

The chunker must:

1. Prefer paragraph boundaries.
2. Prefer sentence boundaries.
3. Avoid cutting inside a sentence.
4. Maintain limited overlap.
5. Avoid tiny chunks.
6. Preserve original order.
7. Assign chunk IDs.

Example:

```dart
TranscriptChunk(
  id: 0,
  text: "...",
  startSentenceIndex: 0,
  endSentenceIndex: 12,
)
```

---

# 12. Token Budget

Do NOT estimate token count purely from character count if the existing LiteRT/Gemma tokenizer can provide token counts.

Create:

```text
TokenCounter
```

Use the actual tokenizer when practical.

Fallback approximation may exist for early testing, but production chunking should prefer actual tokenization.

---

# 13. Phase 6 — Gemma Local Data Source

Create or refactor:

```text
GemmaLocalDataSource
```

Responsibilities:

* Model availability
* Model activation
* Prompt execution
* Generation configuration
* Response cleanup
* Retry handling
* Cancellation if supported

It must NOT know:

* UI
* BLoC
* Repository business logic
* Chunking policy
* Evaluation logic

---

# 14. Gemma Configuration

Initial generation parameters:

```text
temperature = 0.20
topK = 20
topP = 0.90
seed = 47
```

Keep these configurable.

Create:

```text
GemmaGenerationConfig
```

Example:

```dart
class GemmaGenerationConfig {
  final double temperature;
  final int topK;
  final double topP;
  final int seed;
  final int maxTokens;
}
```

Do not hardcode values throughout the codebase.

---

# 15. Phase 7 — Prompt System

Create centralized prompt templates.

Example:

```text
lib/features/summarization/data/prompts/
├── chunk_analysis_prompt.dart
├── local_summary_prompt.dart
├── merge_prompt.dart
├── final_summary_prompt.dart
└── validation_prompt.dart
```

Do not scatter prompt strings throughout services.

---

# 16. Prompt — Chunk Analysis

Goal:

Extract important information without unnecessary prose.

Template:

```text
You are an Arabic information extraction assistant.

Analyze the provided transcript segment.

Rules:
- Use only information explicitly supported by the text.
- Do not invent facts.
- Preserve names, numbers, dates, technical terms, and important relationships.
- Identify the central idea.
- Identify important supporting points.
- Identify important facts.
- Ignore filler and repetition.
- Write in Arabic.

Return exactly:

MAIN:
...

POINTS:
- ...
- ...
- ...

FACTS:
- ...
- ...
- ...

IMPORTANT_TERMS:
- ...
- ...
```

The parser must tolerate minor formatting variation.

Do NOT fail if Gemma slightly changes formatting.

---

# 17. Prompt — Local Summary

Template:

```text
You are an Arabic summarization assistant.

Summarize the provided transcript segment.

Rules:
1. Preserve the main idea.
2. Preserve important facts.
3. Preserve numbers, dates, names, and technical terms.
4. Remove repetition and low-value details.
5. Do not add information that is not supported by the transcript.
6. Do not speculate.
7. Use clear natural Arabic.
8. Do not mention that you are an AI.
9. Do not start with "يتحدث النص عن".
10. Prefer concise connected prose.

SOURCE:
...
```

---

# 18. Phase 8 — Chunk Processing

Implement:

```text
ChunkSummarizer
```

For every chunk:

```text
Chunk
 ↓
Analysis
 ↓
Local Summary
```

Store:

```text
ChunkAnalysis
LocalSummary
```

The pipeline must preserve chunk ordering.

---

# 19. Error Handling

If a chunk fails:

```text
Retry once
```

If retry fails:

```text
Record failure
```

Do not silently discard it.

Possible fallback:

```text
Use cleaned chunk text as evidence for merge
```

The final result must expose:

```text
failedChunkCount
```

in debug metadata.

---

# 20. Phase 9 — Key Fact Aggregation

After processing all chunks:

```text
ChunkAnalysis[]
```

aggregate:

```text
facts
important terms
numbers
entities
main ideas
```

Deduplicate obvious duplicates.

Do not use fuzzy matching aggressively.

Preserve original wording for facts where possible.

---

# 21. Phase 10 — Hierarchical Merge

Do not send all local summaries to Gemma at once.

Implement:

```text
HierarchicalSummaryMerger
```

Example:

```text
S1 + S2 → M1
S3 + S4 → M2
S5 + S6 → M3
...
```

Then:

```text
M1 + M2 → G1
M3 + M4 → G2
...
```

Continue until a manageable number of summaries remains.

---

# 22. Context-Aware Merge

Important:

Do not merge summaries without evidence.

Each merge should receive:

```text
Relevant local summaries
+
Important facts
+
Relevant source excerpts where practical
```

Goal:

```text
summary compression
without losing source grounding
```

The source excerpts should be bounded to avoid excessive context.

---

# 23. Merge Prompt

Use:

```text
You are merging summaries of an Arabic lecture.

Rules:
- Preserve information supported by the source.
- Do not invent new facts.
- Resolve repetition.
- Preserve important relationships.
- Preserve important numbers, names and technical terms.
- Do not add conclusions that are not supported.
- Produce a coherent Arabic synthesis.

LOCAL SUMMARIES:
...

IMPORTANT FACTS:
...

SOURCE EVIDENCE:
...

OUTPUT:
...
```

---

# 24. Phase 11 — Final Synthesis

Implement:

```text
FinalSummaryGenerator
```

Input:

```text
Global merged summaries
+
Global key facts
+
Important entities
+
Important numbers
```

Output:

```text
FinalSummary
```

The final summary should:

* Start directly with the subject.
* Explain the main topic.
* Cover major themes.
* Preserve important conclusions.
* Remove unnecessary examples.
* Avoid repetition.
* Remain faithful to the source.
* Use natural Arabic.

---

# 25. Final Summary Length

Do not hardcode a single summary length.

Support modes:

```text
short
medium
detailed
```

Initial targets:

```text
short:
5–8 bullet points OR 120–180 Arabic words

medium:
250–400 Arabic words

detailed:
500–700 Arabic words
```

These are starting targets, not absolute requirements.

The final output must prioritize information coverage over hitting an exact word count.

---

# 26. Phase 12 — Factuality Validation

Implement lightweight local validation.

Start with deterministic checks.

Extract from source and summary:

```text
numbers
dates
percentages
versions
technical terms
named entities
```

Compare them.

Flag:

```text
NUMBER_MISMATCH
DATE_MISMATCH
ENTITY_MISMATCH
TERM_MISMATCH
```

Do not automatically reject the summary.

Return:

```text
ValidationReport
```

Example:

```text
ValidationReport(
  isSuspicious: true,
  issues: [...]
)
```

---

# 27. Claim Support

Implement a first-pass claim-support system.

Split final summary into claims/sentences.

For each claim:

```text
Claim
 ↓
Search source sentences/chunks
 ↓
Find likely supporting evidence
 ↓
support score
```

Initial implementation can use:

* keyword overlap
* normalized token overlap
* important entity overlap
* number overlap

Do not pretend this is a full semantic entailment model.

Label it:

```text
heuristic support
```

---

# 28. Validation Thresholds

Initial flags:

```text
number mismatch → high severity

date mismatch → high severity

missing important entity → medium severity

unsupported claim → medium/high severity
```

Make thresholds configurable.

---

# 29. Phase 13 — Arabic Quality

Implement basic Arabic-aware normalization for evaluation:

* Remove diacritics for comparison
* Normalize Alef variants
* Normalize whitespace
* Normalize punctuation
* Normalize Arabic/Latin number forms where safe

Do NOT alter the actual user-visible summary.

Normalization is for evaluation only.

---

# 30. Phase 14 — Benchmark Runner

Create a benchmark runner.

Input:

```text
benchmark fixtures
```

Run:

```text
configuration A
configuration B
configuration C
```

Output:

```text
benchmark_results.json
```

Each record:

```json
{
  "configuration": "...",
  "lecture": "...",
  "coverage": 4.2,
  "faithfulness": 4.5,
  "factuality": 4.6,
  "coherence": 4.3,
  "conciseness": 4.1,
  "arabic_quality": 4.4,
  "processing_time_ms": 123456,
  "tokens_per_second": 15.2
}
```

---

# 31. Phase 15 — Configuration Experiments

Test chunk sizes:

```text
300
400
500
600
800
```

Test overlap:

```text
0
25
50
75
```

Test temperature:

```text
0.1
0.2
0.3
```

Do not run every combination over the full benchmark initially.

Use:

```text
3 representative lectures
```

for the first sweep.

Select the best configurations.

Then test finalists against:

```text
10–20 lectures
```

---

# 32. Optimization Objective

The primary optimization target:

```text
Quality
```

Secondary:

```text
Speed
Memory
Battery
```

Do not sacrifice significant summary quality merely to gain generation speed.

Use:

```text
Quality > Speed
```

unless the performance is unusable on-device.

---

# 33. Phase 16 — Caching

Implement optional development cache.

Hash:

```text
SHA-256(
  modelVersion +
  promptVersion +
  chunkText +
  generationConfig
)
```

Cache:

```text
chunk analysis
local summary
merge output
final summary
```

Changing the prompt version must invalidate the cache.

---

# 34. Phase 17 — Cancellation

The user must be able to cancel long summarization jobs if technically supported by the current Gemma integration.

Cancellation should:

* Stop scheduling new chunks.
* Stop pending work where possible.
* Release resources.
* Return a cancelled state.

Do not leave the model in a broken state.

---

# 35. Phase 18 — Memory Management

Never retain every full prompt and full intermediate output in memory unnecessarily.

Process:

```text
chunk
 ↓
result
 ↓
persist/store
 ↓
release
```

Avoid creating multiple copies of large transcript strings.

For long transcripts, use streaming/chunked processing where practical.

---

# 36. Phase 19 — UI Integration

The UI should expose progress states:

```text
Preparing transcript
Analyzing transcript
Summarizing sections
Combining information
Checking summary
Finalizing
Completed
```

Show:

```text
processedChunks
totalChunks
```

when available.

Do not expose technical details such as:

```text
Gemma
LiteRT
tokens
temperature
```

to normal users.

---

# 37. Final UI Output

The final result should contain:

```text
Summary
```

Optionally:

```text
Key points
```

Optionally:

```text
Important facts
```

The primary user-facing output should remain clean.

---

# 38. Streaming

Do not stream every internal stage to the UI.

Internal:

```text
chunk processing
merge
validation
```

should remain hidden.

Only stream:

```text
Final Summary
```

if the existing Gemma API supports stable streaming.

---

# 39. Logging

Development logs should include:

```text
summary job ID
chunk count
chunk size
processing duration
generation duration
tokens generated
failed chunks
validation warnings
```

Do NOT log:

* Private transcript contents by default
* User recordings
* Sensitive personal data

Provide a debug flag.

---

# 40. Privacy

Nutq is an on-device application.

The summarization pipeline must not:

* Upload transcripts.
* Upload audio.
* Call cloud LLMs.
* Send data to analytics services unless already explicitly configured by the app.

All summarization processing must remain local.

---

# 41. Testing Strategy

## Unit Tests

Test:

```text
TranscriptCleaner
SentenceSegmenter
SemanticChunker
TokenCounter
PromptBuilder
ChunkAnalysisParser
SummaryMerger
FactExtractor
Validation
ArabicNormalizer
```

---

# 42. Chunker Tests

Required cases:

### Case 1

Short transcript.

Expected:

```text
1 chunk
```

### Case 2

Long transcript.

Expected:

```text
multiple ordered chunks
```

### Case 3

Sentence boundary.

Expected:

```text
no sentence cut
```

### Case 4

Large paragraph.

Expected:

```text
safe sentence-based split
```

### Case 5

Numbers.

Expected:

```text
numbers preserved
```

---

# 43. Prompt Parser Tests

Gemma output can vary slightly.

The parser must tolerate:

```text
MAIN:
...

POINTS:
...
```

and minor formatting deviations.

Do not build a brittle parser that crashes because one heading is missing.

Fallback:

```text
treat full response as summary
```

when safe.

---

# 44. Integration Tests

Test:

```text
Transcript
 ↓
Cleaner
 ↓
Chunker
 ↓
Gemma mock
 ↓
Merger
 ↓
Validator
 ↓
Final result
```

Use mocked Gemma responses.

Do not require a real model for every CI test.

---

# 45. Golden Tests

Maintain a small set of:

```text
input transcript
expected structural properties
```

Do NOT require exact generated wording.

Instead test:

```text
important number preserved
important entity preserved
main concept present
no forbidden cloud call
```

---

# 46. Performance Tests

Measure:

```text
startup
model load
first generation
chunk processing
merge processing
total processing
memory
```

Run at least on:

```text
iPhone
Android device
```

where available.

Simulator results must not be treated as final mobile performance numbers.

---

# 47. Definition of Done

The implementation is NOT complete until:

### Functional

* [ ] Gemma 3 1B Q4 loads correctly.
* [ ] Arabic transcript can be summarized offline.
* [ ] Short transcript works.
* [ ] Long transcript works.
* [ ] Chunking works.
* [ ] Hierarchical merging works.
* [ ] Final synthesis works.
* [ ] Validation works.
* [ ] UI receives final summary.
* [ ] Cancellation works where supported.

### Quality

* [ ] Main ideas are preserved.
* [ ] Important numbers are preserved.
* [ ] Important names are preserved.
* [ ] Technical terms are preserved.
* [ ] Major hallucinations are reduced.
* [ ] Repetition is reduced.
* [ ] Arabic output is coherent.

### Engineering

* [ ] Clean Architecture maintained.
* [ ] Existing project functionality preserved.
* [ ] Unit tests pass.
* [ ] Integration tests pass.
* [ ] `flutter analyze` passes.
* [ ] `flutter test` passes.
* [ ] No cloud summarization dependency.
* [ ] No unnecessary new dependencies.
* [ ] No hardcoded UI/business logic coupling.

---

# 48. Important Constraint — Do Not Overengineer

The first implementation should NOT contain unnecessary:

* Vector databases
* Embedding models
* RAG
* External APIs
* Large NLP libraries
* Native ML frameworks outside existing LiteRT integration
* Additional LLMs

Start with:

```text
Cleaning
+
Sentence segmentation
+
Chunking
+
Gemma 1B
+
Hierarchical merge
+
Heuristic validation
```

Only introduce additional components when benchmark results demonstrate a measurable need.

---

# 49. Recommended Implementation Order

Claude Code should execute tasks in this exact sequence.

```text
TASK 01
Audit existing summarization code.

TASK 02
Document current architecture.

TASK 03
Create benchmark fixture infrastructure.

TASK 04
Implement baseline benchmark.

TASK 05
Implement evaluation structures.

TASK 06
Implement transcript cleaner.

TASK 07
Implement sentence segmentation.

TASK 08
Implement tokenizer-aware chunking.

TASK 09
Benchmark chunk sizes.

TASK 10
Refactor Gemma into a clean local data source.

TASK 11
Implement chunk analysis.

TASK 12
Implement local chunk summarization.

TASK 13
Benchmark local prompts.

TASK 14
Implement global fact aggregation.

TASK 15
Implement hierarchical merge.

TASK 16
Implement context-aware merge.

TASK 17
Implement final synthesis.

TASK 18
Implement heuristic factuality validation.

TASK 19
Implement complete pipeline use case.

TASK 20
Integrate with BLoC/Cubit.

TASK 21
Integrate UI progress.

TASK 22
Add cancellation.

TASK 23
Add caching.

TASK 24
Run quality benchmark.

TASK 25
Run performance benchmark.

TASK 26
Optimize.

TASK 27
Run complete regression tests.

TASK 28
Produce final implementation report.
```

---

# 50. Claude Code Operating Instructions

At every task:

1. Inspect relevant existing code first.
2. Do not assume file paths.
3. Reuse existing abstractions where appropriate.
4. Make the smallest safe change.
5. Run relevant tests.
6. Run `flutter analyze`.
7. Report what changed.
8. Report test results.
9. Do not move to the next major task if the current task is broken.

For each completed task, record:

```text
Task:
Files changed:
What changed:
Tests:
Performance:
Known issues:
Next task:
```

Save progress in:

```text
docs/summarization_implementation_progress.md
```

---

# 51. Stop Conditions

Claude Code must STOP and ask for approval instead of guessing if:

* Existing Gemma API is incompatible with the planned implementation.
* The model cannot be loaded.
* A dependency must be replaced.
* Existing architecture must be substantially rewritten.
* A platform-specific native change is required.
* A destructive migration is required.
* A new external service is required.
* Existing user data/storage schema must change.
* The current project contains conflicting summarization implementations.

Do not silently make architectural decisions in these cases.

---

# 52. Final Deliverables

At the end, provide:

```text
1. Updated Flutter implementation
2. Benchmark fixtures
3. Evaluation infrastructure
4. Unit tests
5. Integration tests
6. Benchmark results
7. Performance results
8. docs/current_summarization_architecture.md
9. docs/summarization_implementation_progress.md
10. docs/summarization_benchmark.md
```

The final benchmark report must answer:

```text
1. What chunk size performs best?
2. What overlap performs best?
3. What temperature performs best?
4. Does chunk analysis improve quality?
5. Does hierarchical merging improve quality?
6. Does context-aware merging improve faithfulness?
7. How much information is lost?
8. How often are important numbers preserved?
9. How often are hallucinations detected?
10. What is the average processing time?
11. What is the tokens/sec rate?
12. What is the memory impact?
13. What configuration should be used in production?
```

---

# 53. Final Production Pipeline

The final expected implementation is:

```text
                    ┌──────────────┐
                    │     AUDIO    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │      ASR     │
                    └──────┬───────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Transcript Normalizer  │
              └───────────┬────────────┘
                          │
                          ▼
              ┌────────────────────────┐
              │ Sentence Segmenter     │
              └───────────┬────────────┘
                          │
                          ▼
              ┌────────────────────────┐
              │ Token-aware Chunker     │
              └───────────┬────────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
         Chunk 1       Chunk 2       Chunk N
            │             │             │
            ▼             ▼             ▼
        Gemma 1B       Gemma 1B      Gemma 1B
            │             │             │
            ▼             ▼             ▼
       Analysis +      Analysis +    Analysis +
       Summary         Summary       Summary
            │             │             │
            └─────────────┼─────────────┘
                          │
                          ▼
                Global Key Facts
                          │
                          ▼
             Context-Aware Hierarchical
                       Merge
                          │
                          ▼
                  Final Synthesis
                          │
                          ▼
                Heuristic Validation
                          │
                          ▼
                   Final Summary
                          │
                          ▼
                         UI
```

---

# 54. Core Principle

The system should not depend on Gemma 3 1B being "smart enough" to summarize an entire lecture in one shot.

Instead:

```text
                    ALGORITHM
                       +
                 STRUCTURE
                       +
                 SMALL MODEL
                       ↓
              HIGHER RELIABILITY
```

The model is responsible for language understanding and generation.

The application architecture is responsible for:

* Splitting the problem
* Preserving evidence
* Managing context
* Combining information
* Checking important facts
* Measuring quality
* Handling failures

The objective is not to make Gemma 3 1B behave like a larger model.

The objective is to design the pipeline so that a 1B model can produce the best possible Arabic summaries within its limitations.

---

# 55. Final Instruction to Claude Code

Do not claim the system is "high quality" merely because it produces fluent Arabic.

Quality must be demonstrated through benchmark results.

Do not optimize based only on:

```text
speed
```

Do not optimize based only on:

```text
ROUGE
```

The primary production objective is:

```text
Faithful + Complete + Concise + Coherent Arabic Summary
```

with:

```text
Offline
On-device
Gemma 3 1B IT Q4
```

and acceptable mobile performance.

Start by auditing the existing Nutq summarization implementation before changing anything.
