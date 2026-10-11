import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/loop_guard.dart';
import 'package:nutq/features/summarization/domain/text/transcript_cleaner.dart';

void main() {
  group('cleanTranscriptSeams', () {
    test('drops the doubled word at Moonshine line cuts', () {
      expect(cleanTranscriptSeams('شرقي البلاد\nالبلاد.'), 'شرقي\nالبلاد.');
      expect(cleanTranscriptSeams('قبل يومين ح\nحول الهجمة'), 'قبل يومين\nحول الهجمة');
      expect(cleanTranscriptSeams('في\nفي أفغانستان'), 'في أفغانستان');
    });

    test('leaves text without seams alone', () {
      const text = 'السطر الأول هنا\nوالسطر الثاني هناك';
      expect(cleanTranscriptSeams(text), text);
    });

    test('removes every seam in the real transcript', () {
      final raw = File(
        'test/features/summarization/fixtures/aljazeera_af_pk.txt',
      ).readAsStringSync();
      final lines = cleanTranscriptSeams(raw).split('\n');

      var seams = 0;
      for (var i = 0; i < lines.length - 1; i++) {
        final last = lines[i].trim().split(' ').last;
        final first = lines[i + 1].trim().split(' ').first;
        if (first.startsWith(last)) seams++;
      }
      expect(seams, 0);
    });
  });

  group('loopCut', () {
    test('stops a single-word loop, keeping the text before it', () {
      const text = 'إلى أفغانستان حيث استشهد ثلاثة أشخاص من من من من من';
      final cut = loopCut(text)!;
      expect(text.substring(0, cut), 'إلى أفغانستان حيث استشهد ثلاثة أشخاص من');
    });

    test('stops a phrase loop', () {
      const text = 'بيان رسمي باللغة العربية باللغة العربية باللغة العربية';
      final cut = loopCut(text)!;
      expect(text.substring(0, cut), 'بيان رسمي باللغة العربية');
    });

    test('stops a restated sentence at its start', () {
      const sentence = 'وقد استدعى من كل من الحكومة الأفغانية وزارة الخارجية بيانا';
      const text = 'قتل ثلاثة أشخاص. $sentence. وتم تدمير أسلحة. $sentence';
      final cut = loopCut(text)!;
      expect(text.substring(0, cut).trim(), 'قتل ثلاثة أشخاص. $sentence. وتم تدمير أسلحة.');
    });

    test('lets a normal summary through', () {
      const text =
          'قالت الحكومة الأفغانية إن ثلاثة أشخاص قتلوا في غارات '
          'باكستانية على ولاية كونار، بينما قالت باكستان إن ثمانية وعشرين '
          'مسلحا قتلوا في ثلاثة مواقع. والحدود مغلقة منذ نحو سنة.';
      for (var i = 1; i <= text.length; i++) {
        expect(loopCut(text.substring(0, i)), isNull, reason: 'at $i');
      }
    });
  });
}
