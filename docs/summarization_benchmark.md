# Summarization benchmark report

**Status: not yet run on a device.** This environment has no iPhone/Android
device and no way to execute the bundled model, so every number-dependent
question below is unanswered. Nothing here should be read as evidence that
summary quality is good — the plan (§55) is explicit that fluent Arabic is not
proof of quality.

## What exists

- 9 fixtures (`test/summarization/fixtures/`), with the caveats in that folder's README.
- `SummarizationBenchmarkRunner` writes `benchmark_results.json` in the plan §30 shape.
- `BenchmarkConfiguration.chunkSizeSweep / overlapSweep / temperatureSweep` (plan §31).
- `HeuristicSummaryEvaluator`: proxy scores, deterministic. **Coherence is `null`** (human rating required); other scores are proxies, not measurements.
- `BaselineSummarizer` for A/B comparison against the full pipeline.

## How to run it (on a device)

Build a debug entry point that creates `GemmaLocalDataSourceImpl()`, calls
`SummarizationBenchmarkRunner.forDataSource(dataSource).runAll(fixtures, configs)`
and `writeJson(results, file)`, using
`[BenchmarkConfiguration(name: 'baseline', baseline: true), BenchmarkConfiguration(name: 'pipeline')]`
first, then the sweeps on 3 representative lectures. Simulator numbers are not
mobile performance numbers.

## Questions the report must answer (plan §52)

| # | Question | Answer |
|---|---|---|
| 1 | Best chunk size | not measured |
| 2 | Best overlap | not measured |
| 3 | Best temperature | not measured |
| 4 | Does chunk analysis improve quality? | not measured |
| 5 | Does hierarchical merging improve quality? | not measured |
| 6 | Does context-aware merging improve faithfulness? | not measured |
| 7 | How much information is lost? | not measured |
| 8 | How often are important numbers preserved? | not measured (pipeline-level preservation before the model is verified by `golden_test.dart`) |
| 9 | How often are hallucinations detected? | not measured |
| 10 | Average processing time | not measured |
| 11 | Tokens/sec | not measured |
| 12 | Memory impact | not measured |
| 13 | Production configuration | Defaults from the plan (400/50/250/600 tokens, temp 0.2, topK 20, topP 0.9, seed 47) are **unvalidated starting points** |

## Known risks to check on device first

- The model tokenizer (`sizeInTokens`) path and `openSession`/`createSession` coexistence on the `.litertlm` engine.
- Context budget: 4096 tokens shared by prompt + reply; the repository sheds facts/evidence to fit, but real Arabic token density is unmeasured.
- A 1B model may ignore the MAIN/POINTS/FACTS format; the parser falls back to the raw text, but analysis quality then drops.
- Asset size (~584 MB) and first-run install time/storage.
