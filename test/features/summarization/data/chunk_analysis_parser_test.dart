import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/data/parsing/chunk_analysis_parser.dart';

void main() {
  const parser = ChunkAnalysisParser();

  test('parses the exact requested format', () {
    final a = parser.parse(3, '''
MAIN:
الذكاء الاصطناعي يغيّر الصناعة

POINTS:
- أول نقطة
- ثاني نقطة

FACTS:
- بلغ الاستثمار 5 مليارات دولار عام 2024

IMPORTANT_TERMS:
- التعلم العميق
- GPU''');
    expect(a.chunkId, 3);
    expect(a.main, 'الذكاء الاصطناعي يغيّر الصناعة');
    expect(a.points, ['أول نقطة', 'ثاني نقطة']);
    expect(a.facts, ['بلغ الاستثمار 5 مليارات دولار عام 2024']);
    expect(a.importantTerms, ['التعلم العميق', 'GPU']);
    expect(a.usedFallback, isFalse);
  });

  test('tolerates markdown, lowercase headings, missing colons and odd bullets', () {
    final a = parser.parse(0, '''
**Main:** الفكرة هنا
## points
• نقطة ١
* نقطة ٢
1. نقطة ٣
Facts
– حقيقة
**Important terms**
- مصطلح''');
    expect(a.main, 'الفكرة هنا');
    expect(a.points, ['نقطة ١', 'نقطة ٢', 'نقطة ٣']);
    expect(a.facts, ['حقيقة']);
    expect(a.importantTerms, ['مصطلح']);
  });

  test('a missing heading does not break parsing', () {
    final a = parser.parse(0, 'MAIN:\nفكرة\n\nFACTS:\n- حقيقة');
    expect(a.main, 'فكرة');
    expect(a.points, isEmpty);
    expect(a.facts, ['حقيقة']);
    expect(a.importantTerms, isEmpty);
  });

  test('inline heading content is captured', () {
    expect(parser.parse(0, 'MAIN: فكرة مباشرة').main, 'فكرة مباشرة');
  });

  test('template placeholders ("...") are ignored', () {
    final a = parser.parse(0, 'MAIN:\n...\nPOINTS:\n- ...\n- نقطة حقيقية');
    expect(a.main, isEmpty);
    expect(a.points, ['نقطة حقيقية']);
  });

  test('no headings at all → whole response becomes main (fallback)', () {
    final a = parser.parse(0, 'هذا ملخص حر بلا عناوين.');
    expect(a.main, 'هذا ملخص حر بلا عناوين.');
    expect(a.usedFallback, isTrue);
  });

  test('empty response yields an empty analysis and never throws', () {
    final a = parser.parse(7, '   ');
    expect(a.isEmpty, isTrue);
    expect(a.chunkId, 7);
  });
}
