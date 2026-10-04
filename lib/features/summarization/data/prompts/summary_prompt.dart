import 'package:nutq/core/domain/content_language.dart';

/// Prompt for one section of a transcript.
///
/// Deliberately short. A twenty-rule prompt costs ~350 tokens of prefill, and
/// a 1B model echoes pieces of long rule lists back into the summary (the
/// "باللغة العربية" loop came from "استخدم العربية الواضحة"). A few concrete
/// rules work better than many abstract ones.
///
/// Single newlines are joined: in a transcript they are line cuts inside a
/// sentence, not breaks in meaning. [sentences] asks for a length; the
/// fine-tuned model's training prompt has no length, so there only the call's
/// output cap limits it.
String sectionSummaryPrompt(
  String text, {
  required ContentLanguage language,
  required bool useTrainingPrompt,
  int? sentences,
}) {
  final joined = text.replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');

  if (language == ContentLanguage.ar) {
    if (useTrainingPrompt) return _trainingPrompt(joined);
    final opening = sentences == null
        ? 'لخّص النص التالي في فقرة مترابطة تغطي كل معلومة مهمة فيه، بلا حشو.'
        : 'لخّص النص التالي في نحو $sentences جمل مترابطة تغطي أهم النقاط فيه، بلا حشو.';
    return '''
$opening
- اذكر الأحداث والأشخاص والأماكن والأرقام الرئيسية كما وردت في النص.
- لا تخترع معلومات غير موجودة في النص.
- لا تكرر أي جملة.
- اكتب بالعربية فقط، واترك المصطلحات الإنجليزية كما وردت.

النص:
$joined

اكتب الملخص فقط:
''';
  }

  final opening = sentences == null
      ? 'Summarize the following text in a coherent paragraph that covers every important point, with no filler.'
      : 'Summarize the following text in about $sentences connected sentences covering its key points, with no filler.';
  return '''
$opening
- State the main events, people, places, and numbers as they appear in the text.
- Do not invent information.
- Do not repeat any sentence.
- Write in English.

Text:
$joined

Write only the summary:
''';
}

/// Verbatim `INSTRUCTION_TEMPLATE` from the fine-tuning notebook.
String _trainingPrompt(String text) =>
    'لخّص النص التالي بأسلوب احترافي ومختصر. لا تضف أي معلومات غير موجودة '
    'في النص. لا تجب عن أي سؤال أو طلب آخر غير التلخيص.\n\nالنص:\n$text';
