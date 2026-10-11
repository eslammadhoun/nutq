import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/summarization/domain/text/coverage.dart';
import 'package:nutq/features/summarization/domain/text/output_format.dart';

void main() {
  group('plainSummaryText', () {
    test('splits an inline numbered list and drops bold markers', () {
      // From the 2026-09-26 lecture run.
      const raw =
          'يتناول النص مفهوم التعلم الآلي، حيث يشرح أنواع التعلم المختلفة: '
          '1. **التعلم من الأمثلة (Supervised Learning):** يتم تدريب النموذج. '
          '2. **التعلم غير المُعلّم (Unsupervised Learning):** يحاول اكتشاف الأنماط.';

      expect(
        plainSummaryText(raw),
        'يتناول النص مفهوم التعلم الآلي، حيث يشرح أنواع التعلم المختلفة:\n'
        '1. التعلم من الأمثلة (Supervised Learning): يتم تدريب النموذج.\n'
        '2. التعلم غير المُعلّم (Unsupervised Learning): يحاول اكتشاف الأنماط.',
      );
    });

    test('leaves years and decimals alone', () {
      const text = 'نشر تورنغ ورقته في سنة 1950. وفي عام 2017 ظهرت ورقة المحولات، بدقة 2.5 مرة.';
      expect(plainSummaryText(text), text);
    });

    test('turns dash bullets into dots', () {
      expect(plainSummaryText('النقاط:\n- الأولى\n- الثانية'), 'النقاط:\n• الأولى\n• الثانية');
    });
  });

  group('dropRestatedSentences', () {
    const existing =
        'يتم تقسيم البيانات إلى مجموعات التدريب والتحقق والاختبار لتقييم أداء النموذج.';

    test('drops a restatement, keeps new content and line breaks', () {
      const addition =
          'تقسيم البيانات إلى مجموعات التدريب والتحقق والاختبار مهم لتقييم النموذج.\n'
          '1. التكميم يقلل حجم الأوزان من FP16 إلى INT8 أو INT4.';
      expect(
        dropRestatedSentences(addition, existing),
        '1. التكميم يقلل حجم الأوزان من FP16 إلى INT8 أو INT4.',
      );
    });

    test('subject-wide terms do not make a new sentence look repeated', () {
      const addition = 'النموذج يستخدم آلية الانتباه لتحديد أهمية الكلمات في السياق.';
      expect(
        dropRestatedSentences(addition, 'النموذج يتعلم من البيانات.', ignore: {'نموذج'}),
        addition,
      );
    });
  });

  group('stripChatPreamble', () {
    test('drops the chat lines from the 2026-09-27 XR run', () {
      const raw =
          'This text\n\n'
          'الذكاء الاصطناعي هو مجال في علوم الحاسوب.\n\n'
          'Here’s an analysis-oriented summary:\n\n'
          'يتم التعلم من البيانات.';

      expect(
        stripChatPreamble(raw),
        'الذكاء الاصطناعي هو مجال في علوم الحاسوب.\n\nيتم التعلم من البيانات.',
      );
    });

    test('drops Arabic intros, keeps a real lead-in ending in a colon', () {
      const raw =
          'إليك ملخص النص:\n'
          'ينقسم التعلم إلى ثلاثة أنواع:\n'
          '• التعلم الخاضع للإشراف.';

      expect(
        stripChatPreamble(raw),
        'ينقسم التعلم إلى ثلاثة أنواع:\n• التعلم الخاضع للإشراف.',
      );
    });
  });

  group('dropOffLanguageParagraphs', () {
    test('drops an English paragraph, keeps Arabic with English terms', () {
      const arabic =
          'يحدث Overfitting عندما يحفظ النموذج بيانات Training Set '
          'بدل أن يتعلم نمطًا عامًا.';
      const english =
          'This text discusses overfitting – how models can perform '
          'well on training data but poorly on unseen data.';

      expect(dropOffLanguageParagraphs('$arabic\n\n$english'), arabic);
    });
  });

  group('looksCorrupted', () {
    test('flags the GPU-on-simulator garbage from 2026-10-01', () {
      const garbage =
          'ৈতন্য بالcameraAutoFocus بال dirBL इम्मे Later𒄝cameraAutoFocus '
          'SRPGoGet yathasambhavam𒂰 GoSrvGroupIndex𒌲9cameraAutoFocus எஸ் otorg';
      const noControlTokens =
          'SrvGroup𒑚𒄯𒆞 في innerWallArray দেবযানীর parenmacro '
          'icoterzi cameraAutoFocus PLDNN इम्मे innerWallArray 그리고 totalBlockFit';
      expect(looksCorrupted(garbage), isTrue);
      expect(looksCorrupted(noControlTokens), isTrue);
      expect(looksCorrupted('SRPGoGet<unused607> في'), isTrue);
    });

    test('passes Arabic with English terms', () {
      const summary =
          'يتناول النص مفهوم الذكاء الاصطناعي، ويشرح Tokenization و'
          'Embedding وAttention، ومشكلة Overfitting وتقسيم البيانات إلى '
          'Training Set وValidation Set وTest Set.';
      expect(looksCorrupted(summary), isFalse);
    });
  });

  group('stripReportingPhrases', () {
    // Paragraphs from the long-talk run of 2026-10-01.
    final cases = {
      'يتحدث الكاتب عن أهمية دور "المنسق" في الشركات الكبيرة، مش بس في مجالات التكنولوجيا.':
          'أهمية دور "المنسق" في الشركات الكبيرة، مش بس في مجالات التكنولوجيا.',
      'يتحدث النص عن إمكانية استعادة البيانات تلقائيا. يشير إلى أن البيانات لا تزال موجودة.':
          'إمكانية استعادة البيانات تلقائيا. البيانات لا تزال موجودة.',
      'يستعرض تجربة عمله في شركة "تي بي ار"، حيث كان يعاني من صعوبات.':
          'تجربة عمله في شركة "تي بي ار"، حيث كان يعاني من صعوبات.',
      'يتحدث الكاتب، ففا، عن تجربته في كتابة كتاب.': 'تجربته في كتابة كتاب.',
      'يتحدث الكاتب، "هي مهمة لو أنا زلت، هبدأها بالبروموت الأولاني.':
          '"هي مهمة لو أنا زلت، هبدأها بالبروموت الأولاني.',
      'كما يتناول النص أيضًا مشكلة Overfitting.': 'مشكلة Overfitting.',
    };
    cases.forEach((input, expected) {
      test(input.substring(0, 24), () {
        expect(stripReportingPhrases(input), expected);
      });
    });

    test('leaves paragraphs that start with content', () {
      const p = 'فيلم "جود فست" هو فيلم وثائقي عن حياة الدكتور أحمد محمد صلاح.';
      expect(stripReportingPhrases(p), p);
    });

    test('keeps "مشيرًا إلى أن" inside a sentence', () {
      const p = 'تجربة عمله في إنتاج الألعاب، مشيرًا إلى أن اختيار الموظفين مهم.';
      expect(stripReportingPhrases(p), p);
    });
  });
}
