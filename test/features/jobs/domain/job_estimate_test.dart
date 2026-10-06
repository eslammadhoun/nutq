import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/domain/services/job_estimate.dart';

void main() {
  group('JobRates', () {
    test('a measurement moves the rate halfway towards it', () {
      const rates = JobRates(outputTokensPerSecond: 10, outputTokensPerWord: 2);
      final next = rates.afterSummary(
        outputTokens: 400,
        elapsed: const Duration(seconds: 20),
        summaryWords: 100,
      );
      expect(next.outputTokensPerSecond, 15); // measured 20
      expect(next.outputTokensPerWord, 3); // measured 4
    });

    test('a transcription updates the real-time factor and speech rate', () {
      const rates = JobRates(sourceRealTimeFactor: 0.1, spokenWordsPerSecond: 2);
      final next = rates.afterTranscription(
        audio: const Duration(minutes: 10),
        elapsed: const Duration(minutes: 2),
        words: 1800,
      );
      expect(next.sourceRealTimeFactor, closeTo(0.15, 1e-9)); // measured 0.2
      expect(next.spokenWordsPerSecond, closeTo(2.5, 1e-9)); // measured 3
    });

    test('measurements with nothing to learn from change nothing', () {
      const rates = JobRates();
      expect(
        rates
            .afterSummary(outputTokens: 0, elapsed: const Duration(seconds: 5), summaryWords: 0)
            .toJson(),
        rates.toJson(),
      );
      expect(
        rates.afterTranscription(audio: Duration.zero, elapsed: Duration.zero, words: 0).toJson(),
        rates.toJson(),
      );
    });

    test('round-trips through JSON, falling back to defaults for bad values', () {
      const rates = JobRates(outputTokensPerSecond: 12.5);
      expect(JobRates.fromJson(rates.toJson()).outputTokensPerSecond, 12.5);
      final broken = JobRates.fromJson({'outputTokensPerSecond': -1, 'spokenWordsPerSecond': 'x'});
      expect(broken.toJson(), const JobRates().toJson());
    });
  });

  group('JobPlan', () {
    // 10% of the source becomes summary, 2 tokens per summary word, 10 tokens
    // a second; transcription takes a tenth of real time; 2 words a second.
    const rates = JobRates(
      sourceRealTimeFactor: 0.1,
      spokenWordsPerSecond: 2,
      outputTokensPerSecond: 10,
      outputTokensPerWord: 2,
    );
    JobPlan plan({int? words}) =>
        JobPlan(rates: rates, summaryRatio: (_) => 0.1, transcriptWords: words);

    test('a media job is unknown until its audio length is', () {
      final p = plan();
      expect(p.isKnown, isFalse);
      p.audio = const Duration(minutes: 10);
      expect(p.isKnown, isTrue);
      // 600 s audio → 60 s transcribing; 1200 words → 240 tokens → 24 s.
      expect(p.total, const Duration(seconds: 84));
    });

    test('progress is time done over total time, across both steps', () {
      final p = plan()..audio = const Duration(minutes: 10);
      expect(p.duringSource(0.5), closeTo(30 / 84, 1e-9));
      expect(p.duringSource(1), closeTo(60 / 84, 1e-9));
      expect(p.duringSummary(outputTokens: 120), closeTo((60 + 12) / 84, 1e-9));
    });

    test('the real transcript length replaces the guess from the audio', () {
      final p = plan()
        ..audio = const Duration(minutes: 10)
        ..transcriptWords = 600;
      expect(p.expectedOutputTokens, 120);
      expect(p.total, const Duration(seconds: 72));
    });

    test('pasted text is all summary', () {
      final p = plan(words: 1000);
      expect(p.duringSource(1), 0);
      expect(p.duringSummary(outputTokens: 100), closeTo(0.5, 1e-9));
    });

    test('the summary step stops short of the end and follows sections if tokens lag', () {
      final p = plan(words: 1000);
      expect(p.duringSummary(outputTokens: 10000), closeTo(0.98, 1e-9));
      expect(p.duringSummary(outputTokens: 0, sectionFraction: 0.5), closeTo(0.5, 1e-9));
    });
  });
}
