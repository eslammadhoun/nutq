// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نطق';

  @override
  String get appTagline => 'تحويل الكلام العربي إلى نص';

  @override
  String get routeNotFound => 'المسار غير موجود';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAlerts => 'التنبيهات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get errorNoConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorServerUnreachable =>
      'تعذر الوصول إلى الخادم. حاول مرة أخرى لاحقًا.';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب';

  @override
  String get errorInvalidCredentials => 'بيانات الدخول غير صحيحة';

  @override
  String get errorLoginAgain => 'يرجى تسجيل الدخول مرة أخرى';

  @override
  String jobFallbackTitle(String id) {
    return 'مهمة #$id';
  }

  @override
  String jobTodayLabel(String time) {
    return 'اليوم، $time';
  }

  @override
  String get jobYesterdayLabel => 'أمس';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String validationFieldRequired(String field) {
    return '$field مطلوب';
  }

  @override
  String validationMinLength(String field, int min) {
    return 'يجب ألا يقل $field عن $min من الأحرف';
  }

  @override
  String validationMaxLength(String field, int max) {
    return 'يجب ألا يتجاوز $field $max من الأحرف';
  }

  @override
  String get validationEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get validationPasswordLowercase =>
      'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';

  @override
  String get validationPasswordUppercase =>
      'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';

  @override
  String get validationPasswordNumber =>
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';

  @override
  String get validationPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationNameChars =>
      'يمكن أن يحتوي الاسم على الأحرف والمسافات والشرطات والفواصل العليا فقط';

  @override
  String get validationUsernameChars =>
      'يمكن أن يحتوي اسم المستخدم على الأحرف والأرقام و الشرطات السفلية والشرطات فقط';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHidden => '••••••••';

  @override
  String get authShowPassword => 'إظهار';

  @override
  String get authHidePassword => 'إخفاء';

  @override
  String get loginWelcomeTitle => 'أهلاً بعودتك';

  @override
  String get loginWelcomeSubtitle => 'سجّل الدخول إلى حسابك للمتابعة';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginFooterPrompt => 'ليس لديك حساب؟ ';

  @override
  String get loginFooterAction => 'إنشاء حساب';

  @override
  String get registerWelcomeTitle => 'إنشاء حساب';

  @override
  String get registerWelcomeSubtitle =>
      'انضم إلى نطق لبدء تحويل الكلام العربي إلى نص';

  @override
  String get registerUsernameLabel => 'اسم المستخدم';

  @override
  String get registerUsernameHint => 'مثال: ahmed_ali';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerConfirmPasswordHint => 'أعد كتابة كلمة المرور';

  @override
  String get registerSubmit => 'إنشاء حساب';

  @override
  String get registerFooterPrompt => 'لديك حساب بالفعل؟ ';

  @override
  String get registerFooterAction => 'تسجيل الدخول';

  @override
  String get jobsHistoryTitle => 'السجل';

  @override
  String get jobsSearchHint => 'ابحث في التفريغات...';

  @override
  String get jobsFilterAll => 'الكل';

  @override
  String get jobsEmptyTitle => 'لا توجد تفريغات بعد';

  @override
  String get jobsEmptySubtitle => 'أرسل أول ملف صوتي أو فيديو أو نص عربي للبدء';

  @override
  String get sourceAudioFile => 'ملف صوتي';

  @override
  String get sourceVideo => 'فيديو';

  @override
  String get sourceYoutube => 'يوتيوب';

  @override
  String get sourceWebUrl => 'رابط ويب';

  @override
  String get sourceText => 'نص';

  @override
  String get statusDone => 'منجز';

  @override
  String get statusProcessing => 'قيد المعالجة';

  @override
  String get statusQueued => 'في الانتظار';

  @override
  String get statusFailed => 'فشل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get newJobTitle => 'مهمة جديدة';

  @override
  String get newJobLanguageLabel => 'اللغة';

  @override
  String get newJobLanguageArabic => 'العربية (AR)';

  @override
  String get newJobLanguageEnglish => 'الإنجليزية (EN)';

  @override
  String get newJobIdempotencyKeyLabel => 'مفتاح عدم التكرار';

  @override
  String get newJobTextLabel => 'أدخل أو الصق نصك العربي';

  @override
  String get newJobTextPlaceholder =>
      'مثال: أدخل النص العربي هنا للحصول على ملخص...';

  @override
  String newJobCharCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get newJobChooseAudioFile => 'اختر ملف صوتي';

  @override
  String get newJobChooseVideoFile => 'اختر ملف فيديو';

  @override
  String get newJobFormatsAudio => 'MP3 وWAV وM4A · حتى 500 ميجابايت';

  @override
  String get newJobFormatsVideo => 'MP4 وWebM وMOV · حتى 500 ميجابايت';

  @override
  String get newJobYoutubeUrlLabel => 'رابط يوتيوب';

  @override
  String get newJobYoutubeUrlHint => 'https://youtube.com/watch?v=...';

  @override
  String get newJobSubmit => 'إرسال المهمة';

  @override
  String get newJobFileTooLarge => 'حجم الملف المحدد يتجاوز 500 ميجابايت';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSlide1Title => 'حوّل الكلام العربي\nإلى نص';

  @override
  String get onboardingSlide1Subtitle =>
      'سجّل أو ارفع أي ملف صوتي — يقوم نطق\nبتفريغه في ثوانٍ وبدقة عالية.';

  @override
  String get onboardingSlide2Title => 'ملخصات\nبالذكاء الاصطناعي';

  @override
  String get onboardingSlide2Subtitle =>
      'احصل على ملخصات ذكية وأهم النقاط\nورؤى من كل عملية تفريغ.';

  @override
  String get onboardingSlide3Title => 'تصفّح\nسجلّك';

  @override
  String get onboardingSlide3Subtitle =>
      'ابحث وشارك وصدّر كل تفريغاتك\nالسابقة بسهولة.';

  @override
  String get alertsComingSoon => 'التنبيهات — قريباً';

  @override
  String get profileComingSoon => 'الملف الشخصي — قريباً';

  @override
  String get profileLogOut => 'تسجيل الخروج';
}
