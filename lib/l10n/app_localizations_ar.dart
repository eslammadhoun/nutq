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
  String get errorModelNotDownloaded => 'لم يتم تنزيل هذا النموذج بعد';

  @override
  String get errorInsufficientStorage =>
      'لا توجد مساحة تخزين كافية على هذا الجهاز';

  @override
  String get errorInsufficientMemory =>
      'لا توجد ذاكرة كافية متاحة لإتمام هذه العملية';

  @override
  String get errorProcessingCancelled => 'تم إلغاء المعالجة';

  @override
  String get errorAudioDecodeFailed => 'تعذّرت قراءة ملف الصوت هذا';

  @override
  String get errorNativeEngineFailure => 'حدث خطأ ما أثناء المعالجة';

  @override
  String get errorDeviceOffline => 'جهازك غير متصل بالإنترنت';

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
  String get jobDetailTitle => 'تفاصيل المهمة';

  @override
  String get jobDetailTranscriptionComplete => 'اكتمل النسخ';

  @override
  String get jobDetailTranscript => 'النص المفرَّغ';

  @override
  String get jobDetailTranscriptPending => 'النص المفرَّغ غير جاهز بعد.';

  @override
  String get jobDetailAiSummary => 'ملخص الذكاء الاصطناعي';

  @override
  String get jobDetailSummaryPending => 'الملخص غير جاهز بعد.';

  @override
  String get jobDetailDownloadTranscript => 'تنزيل النص';

  @override
  String get jobDetailShare => 'مشاركة';

  @override
  String get jobDetailCopyText => 'نسخ النص';

  @override
  String get jobDetailKeyTakeaways => 'أبرز النقاط';

  @override
  String jobDetailWordCount(int count) {
    return '$count كلمة';
  }

  @override
  String get jobDetailCancelJob => 'إلغاء المهمة';

  @override
  String get jobDetailCancelling => 'جارٍ الإلغاء...';

  @override
  String get jobDetailReconnecting => 'جارٍ إعادة الاتصال...';

  @override
  String get jobDetailJustNow => 'الآن';

  @override
  String jobDetailMinutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String jobDetailHoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String jobDetailDaysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get jobDetailShowMore => 'عرض المزيد';

  @override
  String get jobDetailShowLess => 'عرض أقل';

  @override
  String get profileComingSoon => 'الملف الشخصي — قريباً';

  @override
  String get profileLogOut => 'تسجيل الخروج';

  @override
  String get profileModels => 'نماذج التفريغ الصوتي';

  @override
  String get modelsScreenTitle => 'نماذج التفريغ الصوتي';

  @override
  String get modelsTierBase => 'أساسي';

  @override
  String get modelsTierBaseDescription => 'الأسرع، وأقل استخداماً للتخزين';

  @override
  String get modelsTierSmall => 'صغير';

  @override
  String get modelsTierSmallDescription => 'موصى به — توازن بين الدقة والحجم';

  @override
  String get modelsTierMedium => 'متوسط';

  @override
  String get modelsTierMediumDescription => 'أفضل دقة، وأكبر حجم تحميل';

  @override
  String get modelsDefaultBadge => 'افتراضي';

  @override
  String get modelsInstalled => 'مثبّت';

  @override
  String get modelsNotInstalled => 'غير محمّل';

  @override
  String get modelsDownload => 'تحميل';

  @override
  String get modelsDelete => 'حذف';

  @override
  String get modelsCancelDownload => 'إلغاء';

  @override
  String modelsDownloading(int percent) {
    return 'جارٍ التحميل… $percent%';
  }

  @override
  String modelsSizeMb(String size) {
    return '$size ميغابايت';
  }

  @override
  String modelsSizeGb(String size) {
    return '$size غيغابايت';
  }

  @override
  String get modelsSectionAsr => 'تحويل الكلام إلى نص';

  @override
  String get modelsSectionSummarization => 'التلخيص';

  @override
  String get modelsTierGemma1b => 'جيما 3 - 1 مليار';

  @override
  String get modelsTierGemma1bDescription => 'تلخيص سريع على الجهاز — موصى به';

  @override
  String get modelsTierGemma4b => 'جيما 3 - 4 مليار';

  @override
  String get modelsTierGemma4bDescription => 'تلخيص أعلى جودة، وحجم تحميل أكبر';

  @override
  String modelsRamGateBlocked(String gbRequired) {
    return 'يتطلب جهازاً بذاكرة وصول عشوائي لا تقل عن $gbRequired غيغابايت';
  }

  @override
  String modelsRamUnknownWarning(String gbRequired) {
    return 'تعذّر التحقق من ذاكرة الجهاز المتوفرة — يحتاج هذا النموذج إلى $gbRequired غيغابايت من الذاكرة للعمل بسلاسة';
  }

  @override
  String get summarizeScreenTitle => 'التلخيص';

  @override
  String get summarizeTranscriptHint => 'الصق النص أو اكتبه هنا';

  @override
  String get summarizeLengthShort => 'قصير';

  @override
  String get summarizeLengthMedium => 'متوسط';

  @override
  String get summarizeLengthDetailed => 'مفصّل';

  @override
  String get summarizeAction => 'لخّص';

  @override
  String get summarizeCancel => 'إلغاء';

  @override
  String get summarizeNewSummary => 'تلخيص جديد';

  @override
  String get summarizeStagePreparing => 'تجهيز النص';

  @override
  String get summarizeStageAnalyzing => 'تحليل النص';

  @override
  String get summarizeStageSummarizing => 'تلخيص الأقسام';

  @override
  String get summarizeStageCombining => 'دمج المعلومات';

  @override
  String get summarizeStageChecking => 'مراجعة الملخص';

  @override
  String get summarizeStageFinalizing => 'إنهاء الملخص';

  @override
  String get summarizeStageCompleted => 'اكتمل';

  @override
  String summarizeChunkProgress(int processed, int total) {
    return '$processed من $total أقسام';
  }

  @override
  String get summarizeResultTitle => 'الملخص';

  @override
  String get summarizeKeyPoints => 'النقاط الرئيسية';

  @override
  String get summarizeImportantFacts => 'معلومات مهمة';

  @override
  String get summarizeCheckWarning =>
      'تعذّر التحقق من بعض التفاصيل في هذا الملخص مقابل النص الأصلي. يُرجى مراجعته.';

  @override
  String get summarizeCancelled => 'تم إلغاء التلخيص.';

  @override
  String get summarizeErrorEmpty => 'لا يوجد نص لتلخيصه.';

  @override
  String get summarizeErrorModel => 'نموذج التلخيص على الجهاز غير متاح.';

  @override
  String get summarizeErrorGeneration =>
      'تعذّر إنشاء الملخص. يُرجى المحاولة مرة أخرى.';

  @override
  String get profileSummarize => 'تلخيص نص';

  @override
  String get newJobSourceUnavailable =>
      'يمكن حاليًا تلخيص النص الملصق فقط على هذا الجهاز. مصادر الصوت والفيديو ويوتيوب غير متاحة بعد.';
}
