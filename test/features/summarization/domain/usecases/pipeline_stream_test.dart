import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/entities/cancellation_token.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_failure.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_progress.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';

import '../../support/fake_gemma.dart';

const _config = SummarizationConfig(targetTokens: 60, overlapTokens: 10, minTokens: 30, maxTokens: 90);
final _text = List.generate(
  6,
  (i) => 'في الفقرة رقم $i نناقش موضوعا مهما. بلغ عدد المشاركين 250 شخصا في عام 2024 وقال الدكتور أحمد محمد إن النتائج جيدة.',
).join('\n\n');

void main() {
  late FakeGemma gemma;
  late SummarizeTranscript pipeline;

  setUp(() {
    gemma = FakeGemma();
    pipeline = SummarizeTranscript(repository: SummarizationRepositoryImpl(dataSource: gemma));
  });

  group('SummarizationProgress.fraction', () {
    test('is monotonic across a job and ends at 1.0', () {
      const stages = [
        SummarizationProgress(SummarizationStage.preparing),
        SummarizationProgress(SummarizationStage.analyzing, processedChunks: 0, totalChunks: 4),
        SummarizationProgress(SummarizationStage.summarizing, processedChunks: 2, totalChunks: 4),
        SummarizationProgress(SummarizationStage.summarizing, processedChunks: 4, totalChunks: 4),
        SummarizationProgress(SummarizationStage.combining, processedChunks: 4, totalChunks: 4),
        SummarizationProgress(SummarizationStage.finalizing),
        SummarizationProgress(SummarizationStage.checking),
        SummarizationProgress(SummarizationStage.completed),
      ];
      final values = stages.map((s) => s.fraction).toList();
      for (var i = 1; i < values.length; i++) {
        expect(values[i], greaterThanOrEqualTo(values[i - 1]));
      }
      expect(values.last, 1.0);
      expect(values.every((v) => v >= 0 && v <= 1), isTrue);
    });
  });

  group('SummarizeTranscript.stream', () {
    test('emits progress events in order, then exactly one result, then closes', () async {
      final updates = await pipeline.stream(_text, _config).toList();

      expect(updates.last, isA<SummarizationCompletedUpdate>());
      expect(updates.whereType<SummarizationCompletedUpdate>(), hasLength(1));

      final progress = updates.whereType<SummarizationProgressUpdate>().map((u) => u.progress).toList();
      expect(progress.first.stage, SummarizationStage.preparing);
      expect(progress.last.stage, SummarizationStage.completed);
      final fractions = progress.map((p) => p.fraction).toList();
      for (var i = 1; i < fractions.length; i++) {
        expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]));
      }
    });

    test('events arrive while the job runs, not all at the end', () async {
      final seenCalls = <int>[];
      await for (final u in pipeline.stream(_text, _config)) {
        if (u is SummarizationProgressUpdate) seenCalls.add(gemma.calls);
      }
      // Model-call count grows between events → they were delivered live.
      expect(seenCalls.toSet().length, greaterThan(3));
    });

    test('failures arrive as stream errors', () async {
      await expectLater(
        pipeline.stream('   ', _config),
        emitsThrough(emitsError(isA<SummarizationFailure>())),
      );
    });

    test('cancelling the subscription cancels the job', () async {
      final token = CancellationToken();
      final sub = pipeline.stream(_text, _config, cancellation: token).listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await sub.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('a cancelled token surfaces SummarizationCancelledException as an error', () async {
      final token = CancellationToken();
      gemma.responder = (prompt, call) async {
        if (call == 2) token.cancel();
        return null;
      };
      await expectLater(
        pipeline.stream(_text, _config, cancellation: token),
        emitsThrough(emitsError(isA<SummarizationCancelledException>())),
      );
    });
  });
}
