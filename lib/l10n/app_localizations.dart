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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

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

  /// No description provided for @jobDetailTranscriptLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get jobDetailTranscriptLive;

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

  /// No description provided for @jobStagePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing transcript'**
  String get jobStagePreparing;

  /// No description provided for @jobStageAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing transcript'**
  String get jobStageAnalyzing;

  /// No description provided for @jobStageSummarizing.
  ///
  /// In en, this message translates to:
  /// **'Summarizing sections'**
  String get jobStageSummarizing;

  /// No description provided for @jobStageCombining.
  ///
  /// In en, this message translates to:
  /// **'Combining information'**
  String get jobStageCombining;

  /// No description provided for @jobStageChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking summary'**
  String get jobStageChecking;

  /// No description provided for @jobStageFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing'**
  String get jobStageFinalizing;

  /// No description provided for @jobStageCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get jobStageCompleted;

  /// No description provided for @jobStageSections.
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total} sections'**
  String jobStageSections(int processed, int total);

  /// No description provided for @jobSummaryNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Some details in this summary could not be verified against the transcript. Please review it.'**
  String get jobSummaryNeedsReview;

  /// No description provided for @jobFailureEmptyTranscript.
  ///
  /// In en, this message translates to:
  /// **'There is no transcript text to summarize.'**
  String get jobFailureEmptyTranscript;

  /// No description provided for @jobFailureModelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The on-device summarization model isn\'t available.'**
  String get jobFailureModelUnavailable;

  /// No description provided for @jobFailureGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'The summary could not be generated. Please try again.'**
  String get jobFailureGenerationFailed;

  /// No description provided for @newJobSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Only pasted text can be summarized on this device for now. Audio, video and YouTube sources aren\'t available yet.'**
  String get newJobSourceUnavailable;

  /// No description provided for @jobDetailSummaryComplete.
  ///
  /// In en, this message translates to:
  /// **'Summary Complete'**
  String get jobDetailSummaryComplete;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t access saved jobs on this device. Please try again.'**
  String get errorStorage;

  /// No description provided for @jobDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This job no longer exists.'**
  String get jobDetailNotFound;

  /// No description provided for @jobFailureInterrupted.
  ///
  /// In en, this message translates to:
  /// **'This job was interrupted because the app was closed before it finished.'**
  String get jobFailureInterrupted;

  /// No description provided for @jobStageAcquiring.
  ///
  /// In en, this message translates to:
  /// **'Fetching source'**
  String get jobStageAcquiring;

  /// No description provided for @jobStageTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing audio'**
  String get jobStageTranscribing;

  /// No description provided for @jobFailureSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The source couldn\'t be reached. Check your connection and try again.'**
  String get jobFailureSourceUnavailable;

  /// No description provided for @jobFailureUnsupportedMedia.
  ///
  /// In en, this message translates to:
  /// **'This file\'s format isn\'t supported.'**
  String get jobFailureUnsupportedMedia;

  /// No description provided for @jobFailureTranscriptionFailed.
  ///
  /// In en, this message translates to:
  /// **'The audio couldn\'t be transcribed.'**
  String get jobFailureTranscriptionFailed;

  /// No description provided for @jobFailureInsufficientStorage.
  ///
  /// In en, this message translates to:
  /// **'There isn\'t enough free storage to process this job.'**
  String get jobFailureInsufficientStorage;

  /// No description provided for @backgroundJobTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing · {percent}'**
  String backgroundJobTranscribing(String percent);

  /// No description provided for @backgroundJobPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused · {percent}'**
  String backgroundJobPaused(String percent);

  /// No description provided for @backgroundJobInterruptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcription paused at {percent}'**
  String backgroundJobInterruptedTitle(String percent);

  /// No description provided for @backgroundJobInterruptedBody.
  ///
  /// In en, this message translates to:
  /// **'Another app is playing audio. Open Nutq to continue {title}.'**
  String backgroundJobInterruptedBody(String title);

  /// No description provided for @backgroundJobReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcript ready'**
  String get backgroundJobReadyTitle;

  /// No description provided for @backgroundJobReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Open Nutq to summarize {title}.'**
  String backgroundJobReadyBody(String title);

  /// No description provided for @backgroundJobSummarizing.
  ///
  /// In en, this message translates to:
  /// **'Summarizing · {percent}'**
  String backgroundJobSummarizing(String percent);

  /// No description provided for @backgroundJobWaitingForApp.
  ///
  /// In en, this message translates to:
  /// **'Open Nutq to summarize · {percent}'**
  String backgroundJobWaitingForApp(String percent);

  /// No description provided for @backgroundJobDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary ready'**
  String get backgroundJobDoneTitle;

  /// No description provided for @backgroundJobDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{title} is summarized.'**
  String backgroundJobDoneBody(String title);

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get alertsClearAll;

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet. Finished jobs show up here.'**
  String get alertsEmpty;

  /// No description provided for @alertsUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled job'**
  String get alertsUntitled;

  /// No description provided for @alertJobDone.
  ///
  /// In en, this message translates to:
  /// **'Summary ready'**
  String get alertJobDone;

  /// No description provided for @alertJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Job failed'**
  String get alertJobFailed;

  /// No description provided for @alertBannerDone.
  ///
  /// In en, this message translates to:
  /// **'Summary ready: {title}'**
  String alertBannerDone(String title);

  /// No description provided for @alertBannerFailed.
  ///
  /// In en, this message translates to:
  /// **'Job failed: {title}'**
  String alertBannerFailed(String title);

  /// No description provided for @alertBannerView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get alertBannerView;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileTitle;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get profileStorage;

  /// No description provided for @profileStorageSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No jobs} =1{1 job} other{{count} jobs}} · {size}'**
  String profileStorageSummary(int count, String size);

  /// No description provided for @profileDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all jobs'**
  String get profileDeleteAll;

  /// No description provided for @profileDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all jobs?'**
  String get profileDeleteAllTitle;

  /// No description provided for @profileDeleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every job is deleted with its transcript, summary and media file. This can\'t be undone.'**
  String get profileDeleteAllBody;

  /// No description provided for @profileDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteAllConfirm;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @profileOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Everything runs on this phone. Nothing is uploaded.'**
  String get profileOnDevice;

  /// No description provided for @jobFailureNoSubtitles.
  ///
  /// In en, this message translates to:
  /// **'This video has no subtitles in the chosen language. Try the other language.'**
  String get jobFailureNoSubtitles;

  /// No description provided for @newJobYoutubeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a YouTube link.'**
  String get newJobYoutubeInvalid;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

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
