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
  String get validationPasswordLowercase => 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';

  @override
  String get validationPasswordUppercase => 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';

  @override
  String get validationPasswordNumber => 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';

  @override
  String get validationPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationNameChars =>
      'يمكن أن يحتوي الاسم على الأحرف والمسافات والشرطات والفواصل العليا فقط';

  @override
  String get validationUsernameChars =>
      'يمكن أن يحتوي اسم المستخدم على الأحرف والأرقام و الشرطات السفلية والشرطات فقط';

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
  String get newJobTextLabel => 'أدخل أو الصق نصك العربي';

  @override
  String get newJobTextPlaceholder => 'مثال: أدخل النص العربي هنا للحصول على ملخص...';

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
  String get onboardingSlide3Subtitle => 'ابحث وشارك وصدّر كل تفريغاتك\nالسابقة بسهولة.';

  @override
  String get jobDetailTitle => 'تفاصيل المهمة';

  @override
  String get jobDetailTranscriptionComplete => 'اكتمل النسخ';

  @override
  String get jobDetailTranscript => 'النص المفرَّغ';

  @override
  String get jobDetailTranscriptPending => 'النص المفرَّغ غير جاهز بعد.';

  @override
  String get jobDetailTranscriptLive => 'مباشر';

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
  String get jobStagePreparing => 'تجهيز النص';

  @override
  String get jobStageAnalyzing => 'تحليل النص';

  @override
  String get jobStageSummarizing => 'تلخيص الأقسام';

  @override
  String get jobStageCombining => 'دمج المعلومات';

  @override
  String get jobStageChecking => 'مراجعة الملخص';

  @override
  String get jobStageFinalizing => 'إنهاء الملخص';

  @override
  String get jobStageCompleted => 'اكتمل';

  @override
  String jobStageSections(int processed, int total) {
    return '$processed من $total أقسام';
  }

  @override
  String get jobSummaryNeedsReview =>
      'تعذّر التحقق من بعض التفاصيل في هذا الملخص مقابل النص الأصلي. يُرجى مراجعته.';

  @override
  String get jobFailureEmptyTranscript => 'لا يوجد نص لتلخيصه.';

  @override
  String get jobFailureModelUnavailable => 'نموذج التلخيص على الجهاز غير متاح.';

  @override
  String get jobFailureGenerationFailed => 'تعذّر إنشاء الملخص. يُرجى المحاولة مرة أخرى.';

  @override
  String get newJobSourceUnavailable =>
      'يمكن حاليًا تلخيص النص الملصق فقط على هذا الجهاز. مصادر الصوت والفيديو ويوتيوب غير متاحة بعد.';

  @override
  String get jobDetailSummaryComplete => 'اكتمل التلخيص';

  @override
  String get errorStorage =>
      'تعذّر الوصول إلى المهام المحفوظة على هذا الجهاز. يُرجى المحاولة مرة أخرى.';

  @override
  String get jobDetailNotFound => 'لم تعد هذه المهمة موجودة.';

  @override
  String get jobFailureInterrupted => 'توقفت هذه المهمة لأن التطبيق أُغلق قبل أن تنتهي.';

  @override
  String get jobStageAcquiring => 'جارٍ جلب المصدر';

  @override
  String get jobStageTranscribing => 'تفريغ الصوت';

  @override
  String get jobFailureSourceUnavailable =>
      'تعذّر الوصول إلى المصدر. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get jobFailureUnsupportedMedia => 'صيغة هذا الملف غير مدعومة.';

  @override
  String get jobFailureTranscriptionFailed => 'تعذّر تفريغ الصوت.';

  @override
  String get jobFailureInsufficientStorage => 'لا توجد مساحة تخزين كافية لمعالجة هذه المهمة.';

  @override
  String backgroundJobTranscribing(String percent) {
    return 'جارٍ التفريغ · $percent';
  }

  @override
  String backgroundJobPaused(String percent) {
    return 'متوقف مؤقتًا · $percent';
  }

  @override
  String backgroundJobInterruptedTitle(String percent) {
    return 'توقف التفريغ عند $percent';
  }

  @override
  String backgroundJobInterruptedBody(String title) {
    return 'تطبيق آخر يشغّل الصوت. افتح نطق لمتابعة $title.';
  }

  @override
  String get backgroundJobReadyTitle => 'النص جاهز';

  @override
  String backgroundJobReadyBody(String title) {
    return 'افتح نطق لتلخيص $title.';
  }

  @override
  String backgroundJobSummarizing(String percent) {
    return 'جارٍ التلخيص · $percent';
  }

  @override
  String backgroundJobWaitingForApp(String percent) {
    return 'افتح نطق للتلخيص · $percent';
  }

  @override
  String get backgroundJobDoneTitle => 'الملخص جاهز';

  @override
  String backgroundJobDoneBody(String title) {
    return 'تم تلخيص $title.';
  }

  @override
  String get alertsTitle => 'التنبيهات';

  @override
  String get alertsClearAll => 'مسح الكل';

  @override
  String get alertsEmpty => 'لا توجد تنبيهات بعد. تظهر هنا المهام المنتهية.';

  @override
  String get alertsUntitled => 'مهمة بلا عنوان';

  @override
  String get alertJobDone => 'الملخص جاهز';

  @override
  String get alertJobFailed => 'فشلت المهمة';

  @override
  String alertBannerDone(String title) {
    return 'الملخص جاهز: $title';
  }

  @override
  String alertBannerFailed(String title) {
    return 'فشلت المهمة: $title';
  }

  @override
  String get alertBannerView => 'عرض';

  @override
  String get profileTitle => 'الإعدادات';

  @override
  String get profileAppearance => 'المظهر';

  @override
  String get profileThemeSystem => 'النظام';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileStorage => 'التخزين';

  @override
  String profileStorageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return '$_temp0 · $size';
  }

  @override
  String get profileDeleteAll => 'حذف كل المهام';

  @override
  String get profileDeleteAllTitle => 'حذف كل المهام؟';

  @override
  String get profileDeleteAllBody =>
      'ستُحذف كل مهمة مع نصها وملخصها وملفها. لا يمكن التراجع عن ذلك.';

  @override
  String get profileDeleteAllConfirm => 'حذف';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileAbout => 'حول التطبيق';

  @override
  String get profileVersion => 'الإصدار';

  @override
  String get profileOnDevice => 'كل شيء يعمل على هذا الهاتف، ولا يُرفع أي شيء.';
}
