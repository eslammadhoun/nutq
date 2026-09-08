import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/ml/llm/summary_response_parser.dart';

void main() {
  group('SummaryResponseParser', () {
    const parser = SummaryResponseParser();

    test('parses valid JSON', () {
      const raw = '''
{
  "summary_text": "ملخص الاجتماع",
  "tone_and_format": "formal meeting",
  "takeaways": [
    {"text": "القرار الأول"},
    {"text": "القرار الثاني"}
  ]
}
''';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.summaryText, 'ملخص الاجتماع');
      expect(summary.toneAndFormat, 'formal meeting');
      expect(summary.takeaways, [
        {'text': 'القرار الأول'},
        {'text': 'القرار الثاني'},
      ]);
      expect(summary.modelName, 'gemma-3-1b-it');
      expect(summary.promptVersion, 'v1');
    });

    test('parses JSON wrapped in a ```json fenced code block', () {
      const raw = '''
Sure, here is the summary:
```json
{
  "summary_text": "hello world",
  "tone_and_format": "casual",
  "takeaways": [{"text": "one"}]
}
```
''';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.summaryText, 'hello world');
      expect(summary.toneAndFormat, 'casual');
      expect(summary.takeaways, [
        {'text': 'one'},
      ]);
    });

    test('parses JSON wrapped in a bare ``` fenced code block (no "json" tag)', () {
      const raw = '''
```
{"summary_text": "x", "tone_and_format": "y", "takeaways": []}
```
''';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.summaryText, 'x');
      expect(summary.toneAndFormat, 'y');
      expect(summary.takeaways, isEmpty);
    });

    test('extracts JSON with stray prose before/after the object', () {
      const raw = 'Here you go: {"summary_text": "s", "tone_and_format": "t", "takeaways": []} Hope that helps!';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.summaryText, 's');
      expect(summary.toneAndFormat, 't');
    });

    test('falls back to raw text as summaryText on completely malformed output', () {
      const raw = 'this is not json at all, just rambling prose from the model.';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1', tokensIn: 10, tokensOut: 20);

      expect(summary.summaryText, raw);
      expect(summary.toneAndFormat, '');
      expect(summary.takeaways, isEmpty);
      expect(summary.tokensIn, 10);
      expect(summary.tokensOut, 20);
    });

    test('falls back gracefully when JSON is syntactically broken (truncated)', () {
      const raw = '{"summary_text": "cut off mid strea';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.summaryText, raw);
      expect(summary.takeaways, isEmpty);
    });

    test('tolerates takeaways entries that are plain strings instead of objects', () {
      const raw = '{"summary_text": "s", "tone_and_format": "t", "takeaways": ["a", "b"]}';

      final summary = parser.parse(raw, modelName: 'gemma-3-1b-it', promptVersion: 'v1');

      expect(summary.takeaways, [
        {'text': 'a'},
        {'text': 'b'},
      ]);
    });
  });
}
