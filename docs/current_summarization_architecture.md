# Summarization architecture

On-device summarization, ported from `gemma_playground` (October 2026), where it was tuned on an
iPhone XR and the iOS Simulator against two Arabic fixtures
(`test/features/summarization/fixtures/`). It replaced an earlier pipeline (chunk → analyze →
hierarchical merge → final synthesis → validate) that had never been run against the real model;
see git history before branch `feature/playground-summarizer`.

## Model

`gemma3-1b-arabic-summarizer-v3_q4_block32_ekv2048.litertlm` (579 MB): Gemma 3 1B fine-tuned on
Arabic news summaries (XLSum + arabsummaries), int4, 2048-token context. It is selected in
`data/datasources/summarizer_model.dart` (`activeSummarizerModel`). Arabic summaries use the exact
instruction it was fine-tuned on; English summaries use a short generic prompt
(`data/prompts/summary_prompt.dart`).

The file is bundled as an asset but not committed (`assets/models/*.litertlm` is ignored). Copy it
from `gemma_playground/assets/models/`.

**Backend:** GPU, with the plugin falling back to CPU by itself if the GPU fails to start. The iOS
Simulator always uses the CPU: its emulated Metal makes the GPU produce garbage (the
`nutq/device` `isSimulator` channel in `AppDelegate.swift`). Android has not been measured yet.

## Pipeline (`SummarizeTranscript`)

1. **Clean**: remove the doubled words Moonshine leaves where it cuts a line
   (`cleanTranscriptSeams`). Under `minWordsToSummarize` (20) words the text is kept as its own
   summary and the model is never loaded.
2. **Analyze** (in an isolate): split into units and score them (`KeyLineExtractor`,
   `CoverageTracker`). Filler such as greetings and hand-overs is dropped. Units scoring at least
   the median are *key points*.
3. **Size the summary**: `summaryRatio` is 15% of the source for a few-minute clip, falling to 6%
   for a 100-minute lecture, then scaled by `SummaryLength` (short 0.6×, medium 1×, detailed 1.6×).
   A 1B model writes about 80 words per call whatever it is asked, so the length is set by the
   number of sections: source words per section = 80 / ratio.
4. **Summarize each section** in source order, one call each, streaming into the visible summary.
   A section that writes less than a third of its share is retried once with only its key points.
5. **Assemble**: paragraphs in source order. Each paragraph loses its "يتحدث الكاتب عن…" opener,
   and sentences that restate an earlier paragraph are dropped.

There is no merge step. A 1B model merging summaries loses detail and repeats itself, and every
merge costs another full prefill.

## Guards on every call (`GemmaLocalDataSourceImpl`)

- **Loop cut**: generation stops as soon as the tail repeats (`loopCut`), and the loop is cut off.
- **Garbage abort**: after 40 tokens, output mixing four or more scripts or containing control
  tokens stops the call. The job then fails without a retry, because the same backend would fail
  again.
- **Cap trim**: a reply that hits its output cap is cut back to its last full sentence.
- **Cleanup** (`SummarizationRepositoryImpl.cleanSummary`): removes an echoed prompt, chat
  preambles ("إليك ملخص النص:"), paragraphs in the wrong language (Arabic summaries only), loops
  and markdown.

A section whose call fails or leaves nothing usable is left out, and the summary is flagged
`needsReview`. The job fails only when no section produced anything.

## Logging

In debug and profile builds each run logs one `[summarizer] …` line, with counts and timings only, never text.
It uses the same fields as gemma_playground's line, so device runs from the two apps can be
compared.

## Known gaps

- **Android:** not benchmarked. The Redmi 15C GPU vs CPU comparison is still open.
- **Mismatched languages:** an Arabic source with an English summary (or the reverse) has not been
  evaluated. The fine-tuned model was trained only on Arabic → Arabic.
- **No key takeaways:** the pipeline doesn't produce them, so `Summary.takeaways` is always empty
  and the Job Detail takeaways section never shows.
