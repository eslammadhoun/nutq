# Summarization benchmark fixtures

Nine Arabic transcripts (3 short, 3 medium, 3 long) in the format from
`nutq-implimentation-plan.md` §7, covering MSA, conversational/Levantine
speech, technical talk with English terms, numbers/dates, repetition and
long-context dependencies.

**Known limitations — read before trusting any score:**

- `reference_summary` is a **draft written by Claude, not a human**
  (`reference_author` says so). The plan requires human-written references;
  replace or review these before using the results as a quality verdict.
- "Long" here means ~250–350 words (2–3 chunks at the default chunk size).
  Real 30–60 minute lectures are ~4,000+ words. Add real long transcripts
  before drawing conclusions about long-context behavior.
- The preferred final dataset is 10 short / 10 medium / 10 long.

`test/summarization/fixtures_test.dart` validates that every important
number and entity really occurs in its transcript.
