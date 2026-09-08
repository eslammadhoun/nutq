import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Nutq'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Arabic Speech Transcription'**
  String get appTagline;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'v {version}'**
  String versionLabel(String version);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// No description provided for @errorServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Please try again later.'**
  String get errorServerUnreachable;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get errorTimeout;

  /// No description provided for @errorModelNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This model hasn\'t been downloaded yet'**
  String get errorModelNotDownloaded;

  /// No description provided for @errorInsufficientStorage.
  ///
  /// In en, this message translates to:
  /// **'Not enough free storage on this device'**
  String get errorInsufficientStorage;

  /// No description provided for @errorInsufficientMemory.
  ///
  /// In en, this message translates to:
  /// **'Not enough available memory to do this'**
  String get errorInsufficientMemory;

  /// No description provided for @errorProcessingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Processing was cancelled'**
  String get errorProcessingCancelled;

  /// No description provided for @errorAudioDecodeFailed.
  ///
  /// In en, this message translates to:
  /// **'This audio file couldn\'t be read'**
  String get errorAudioDecodeFailed;

  /// No description provided for @errorNativeEngineFailure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during processing'**
  String get errorNativeEngineFailure;

  /// No description provided for @errorDeviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Your device is offline'**
  String get errorDeviceOffline;

  /// No description provided for @jobFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Job #{id}'**
  String jobFallbackTitle(String id);

  /// No description provided for @jobTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String jobTodayLabel(String time);

  /// No description provided for @jobYesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get jobYesterdayLabel;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationFieldRequired(String field);

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at least {min} characters'**
  String validationMinLength(String field, int min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must not exceed {max} characters'**
  String validationMaxLength(String field, int max);

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get validationPasswordLowercase;

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get validationPasswordUppercase;

  /// No description provided for @validationPasswordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get validationPasswordNumber;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationNameChars.
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters, spaces, hyphens, and apostrophes'**
  String get validationNameChars;

  /// No description provided for @validationUsernameChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, underscores, and hyphens'**
  String get validationUsernameChars;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHidden.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHidden;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get authHidePassword;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginSubmit;

  /// No description provided for @loginFooterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginFooterPrompt;

  /// No description provided for @loginFooterAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginFooterAction;

  /// No description provided for @registerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerWelcomeTitle;

  /// No description provided for @registerWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Nutq to start transcribing Arabic speech'**
  String get registerWelcomeSubtitle;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ahmed_ali'**
  String get registerUsernameHint;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerSubmit;

  /// No description provided for @registerFooterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerFooterPrompt;

  /// No description provided for @registerFooterAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registerFooterAction;

  /// No description provided for @jobsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get jobsHistoryTitle;

  /// No description provided for @jobsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transcriptions...'**
  String get jobsSearchHint;

  /// No description provided for @jobsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get jobsFilterAll;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transcriptions yet'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit your first Arabic audio, video, \nor text to get started'**
  String get jobsEmptySubtitle;

  /// No description provided for @sourceAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio File'**
  String get sourceAudioFile;

  /// No description provided for @sourceVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get sourceVideo;

  /// No description provided for @sourceYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get sourceYoutube;

  /// No description provided for @sourceWebUrl.
  ///
  /// In en, this message translates to:
  /// **'Web URL'**
  String get sourceWebUrl;

  /// No description provided for @sourceText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get sourceText;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @newJobTitle.
  ///
  /// In en, this message translates to:
  /// **'New Job'**
  String get newJobTitle;

  /// No description provided for @newJobLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get newJobLanguageLabel;

  /// No description provided for @newJobLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic (AR)'**
  String get newJobLanguageArabic;

  /// No description provided for @newJobLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (EN)'**
  String get newJobLanguageEnglish;

  /// No description provided for @newJobIdempotencyKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Idempotency Key'**
  String get newJobIdempotencyKeyLabel;

  /// No description provided for @newJobTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste your Arabic text'**
  String get newJobTextLabel;

  /// No description provided for @newJobTextPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: enter Arabic text here to get a summary...'**
  String get newJobTextPlaceholder;

  /// No description provided for @newJobCharCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String newJobCharCounter(int count, int max);

  /// No description provided for @newJobChooseAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Choose audio file'**
  String get newJobChooseAudioFile;

  /// No description provided for @newJobChooseVideoFile.
  ///
  /// In en, this message translates to:
  /// **'Choose video file'**
  String get newJobChooseVideoFile;

  /// No description provided for @newJobFormatsAudio.
  ///
  /// In en, this message translates to:
  /// **'MP3, WAV, M4A · up to 500MB'**
  String get newJobFormatsAudio;

  /// No description provided for @newJobFormatsVideo.
  ///
  /// In en, this message translates to:
  /// **'MP4, WebM, MOV · up to 500MB'**
  String get newJobFormatsVideo;

  /// No description provided for @newJobYoutubeUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get newJobYoutubeUrlLabel;

  /// No description provided for @newJobYoutubeUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://youtube.com/watch?v=...'**
  String get newJobYoutubeUrlHint;

  /// No description provided for @newJobSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Job'**
  String get newJobSubmit;

  /// No description provided for @newJobFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Selected file exceeds the 500 MB limit'**
  String get newJobFileTooLarge;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Turn Arabic Speech\ninto Text'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record or upload any audio — Nutq\ntranscribes it in seconds with precision.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered\nSummaries'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get smart summaries, key takeaways,\nand insights from every transcription.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Browse Your\nHistory'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, share, and export all your\npast transcriptions with ease.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @alertsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Alerts — coming soon'**
  String get alertsComingSoon;

  /// No description provided for @jobDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Detail'**
  String get jobDetailTitle;

  /// No description provided for @jobDetailTranscriptionComplete.
  ///
  /// In en, this message translates to:
  /// **'Transcription Complete'**
  String get jobDetailTranscriptionComplete;

  /// No description provided for @jobDetailTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get jobDetailTranscript;

  /// No description provided for @jobDetailTranscriptPending.
  ///
  /// In en, this message translates to:
  /// **'The transcript isn\'t ready yet.'**
  String get jobDetailTranscriptPending;

  /// No description provided for @jobDetailAiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get jobDetailAiSummary;

  /// No description provided for @jobDetailSummaryPending.
  ///
  /// In en, this message translates to:
  /// **'The summary isn\'t ready yet.'**
  String get jobDetailSummaryPending;

  /// No description provided for @jobDetailDownloadTranscript.
  ///
  /// In en, this message translates to:
  /// **'Download Transcript'**
  String get jobDetailDownloadTranscript;

  /// No description provided for @jobDetailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get jobDetailShare;

  /// No description provided for @jobDetailCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get jobDetailCopyText;

  /// No description provided for @jobDetailKeyTakeaways.
  ///
  /// In en, this message translates to:
  /// **'KEY TAKEAWAYS'**
  String get jobDetailKeyTakeaways;

  /// No description provided for @jobDetailWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String jobDetailWordCount(int count);

  /// No description provided for @jobDetailCancelJob.
  ///
  /// In en, this message translates to:
  /// **'Cancel Job'**
  String get jobDetailCancelJob;

  /// No description provided for @jobDetailCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get jobDetailCancelling;

  /// No description provided for @jobDetailReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get jobDetailReconnecting;

  /// No description provided for @jobDetailJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get jobDetailJustNow;

  /// No description provided for @jobDetailMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String jobDetailMinutesAgo(int count);

  /// No description provided for @jobDetailHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String jobDetailHoursAgo(int count);

  /// No description provided for @jobDetailDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String jobDetailDaysAgo(int count);

  /// No description provided for @jobDetailShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get jobDetailShowMore;

  /// No description provided for @jobDetailShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get jobDetailShowLess;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile — coming soon'**
  String get profileComingSoon;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileModels.
  ///
  /// In en, this message translates to:
  /// **'Speech models'**
  String get profileModels;

  /// No description provided for @modelsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech Models'**
  String get modelsScreenTitle;

  /// No description provided for @modelsTierBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get modelsTierBase;

  /// No description provided for @modelsTierBaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Fastest, lowest storage use'**
  String get modelsTierBaseDescription;

  /// No description provided for @modelsTierSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get modelsTierSmall;

  /// No description provided for @modelsTierSmallDescription.
  ///
  /// In en, this message translates to:
  /// **'Recommended — balanced accuracy and size'**
  String get modelsTierSmallDescription;

  /// No description provided for @modelsTierMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get modelsTierMedium;

  /// No description provided for @modelsTierMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Best accuracy, largest download'**
  String get modelsTierMediumDescription;

  /// No description provided for @modelsDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get modelsDefaultBadge;

  /// No description provided for @modelsInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get modelsInstalled;

  /// No description provided for @modelsNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get modelsNotInstalled;

  /// No description provided for @modelsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get modelsDownload;

  /// No description provided for @modelsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get modelsDelete;

  /// No description provided for @modelsCancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get modelsCancelDownload;

  /// No description provided for @modelsDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String modelsDownloading(int percent);

  /// No description provided for @modelsSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String modelsSizeMb(String size);

  /// No description provided for @modelsSizeGb.
  ///
  /// In en, this message translates to:
  /// **'{size} GB'**
  String modelsSizeGb(String size);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
