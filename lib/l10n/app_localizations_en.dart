// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nutq';

  @override
  String get appTagline => 'Arabic Speech Transcription';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String get navHome => 'Home';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String versionLabel(String version) {
    return 'v $version';
  }

  @override
  String get retry => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorServerUnreachable =>
      'Can\'t reach the server. Please try again later.';

  @override
  String get errorTimeout => 'Request timed out';

  @override
  String get errorModelNotDownloaded =>
      'This model hasn\'t been downloaded yet';

  @override
  String get errorInsufficientStorage =>
      'Not enough free storage on this device';

  @override
  String get errorInsufficientMemory =>
      'Not enough available memory to do this';

  @override
  String get errorProcessingCancelled => 'Processing was cancelled';

  @override
  String get errorAudioDecodeFailed => 'This audio file couldn\'t be read';

  @override
  String get errorNativeEngineFailure =>
      'Something went wrong during processing';

  @override
  String get errorDeviceOffline => 'Your device is offline';

  @override
  String jobFallbackTitle(String id) {
    return 'Job #$id';
  }

  @override
  String jobTodayLabel(String time) {
    return 'Today, $time';
  }

  @override
  String get jobYesterdayLabel => 'Yesterday';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String validationFieldRequired(String field) {
    return '$field is required';
  }

  @override
  String validationMinLength(String field, int min) {
    return '$field must be at least $min characters';
  }

  @override
  String validationMaxLength(String field, int max) {
    return '$field must not exceed $max characters';
  }

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationPasswordLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get validationPasswordUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get validationPasswordNumber =>
      'Password must contain at least one number';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get validationNameChars =>
      'Name can only contain letters, spaces, hyphens, and apostrophes';

  @override
  String get validationUsernameChars =>
      'Username can only contain letters, numbers, underscores, and hyphens';

  @override
  String get authEmailLabel => 'Email address';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHidden => '••••••••';

  @override
  String get authShowPassword => 'Show';

  @override
  String get authHidePassword => 'Hide';

  @override
  String get loginWelcomeTitle => 'Welcome back';

  @override
  String get loginWelcomeSubtitle => 'Sign in to your account to continue';

  @override
  String get loginSubmit => 'Log In';

  @override
  String get loginFooterPrompt => 'Don\'t have an account? ';

  @override
  String get loginFooterAction => 'Sign up';

  @override
  String get registerWelcomeTitle => 'Create Account';

  @override
  String get registerWelcomeSubtitle =>
      'Join Nutq to start transcribing Arabic speech';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameHint => 'e.g. ahmed_ali';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordHint => 'Repeat your password';

  @override
  String get registerSubmit => 'Create Account';

  @override
  String get registerFooterPrompt => 'Already have an account? ';

  @override
  String get registerFooterAction => 'Log in';

  @override
  String get jobsHistoryTitle => 'History';

  @override
  String get jobsSearchHint => 'Search transcriptions...';

  @override
  String get jobsFilterAll => 'All';

  @override
  String get jobsEmptyTitle => 'No transcriptions yet';

  @override
  String get jobsEmptySubtitle =>
      'Submit your first Arabic audio, video, \nor text to get started';

  @override
  String get sourceAudioFile => 'Audio File';

  @override
  String get sourceVideo => 'Video';

  @override
  String get sourceYoutube => 'YouTube';

  @override
  String get sourceWebUrl => 'Web URL';

  @override
  String get sourceText => 'Text';

  @override
  String get statusDone => 'Done';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get newJobTitle => 'New Job';

  @override
  String get newJobLanguageLabel => 'Language';

  @override
  String get newJobLanguageArabic => 'Arabic (AR)';

  @override
  String get newJobLanguageEnglish => 'English (EN)';

  @override
  String get newJobIdempotencyKeyLabel => 'Idempotency Key';

  @override
  String get newJobTextLabel => 'Enter or paste your Arabic text';

  @override
  String get newJobTextPlaceholder =>
      'Example: enter Arabic text here to get a summary...';

  @override
  String newJobCharCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get newJobChooseAudioFile => 'Choose audio file';

  @override
  String get newJobChooseVideoFile => 'Choose video file';

  @override
  String get newJobFormatsAudio => 'MP3, WAV, M4A · up to 500MB';

  @override
  String get newJobFormatsVideo => 'MP4, WebM, MOV · up to 500MB';

  @override
  String get newJobYoutubeUrlLabel => 'YouTube URL';

  @override
  String get newJobYoutubeUrlHint => 'https://youtube.com/watch?v=...';

  @override
  String get newJobSubmit => 'Submit Job';

  @override
  String get newJobFileTooLarge => 'Selected file exceeds the 500 MB limit';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSlide1Title => 'Turn Arabic Speech\ninto Text';

  @override
  String get onboardingSlide1Subtitle =>
      'Record or upload any audio — Nutq\ntranscribes it in seconds with precision.';

  @override
  String get onboardingSlide2Title => 'AI-Powered\nSummaries';

  @override
  String get onboardingSlide2Subtitle =>
      'Get smart summaries, key takeaways,\nand insights from every transcription.';

  @override
  String get onboardingSlide3Title => 'Browse Your\nHistory';

  @override
  String get onboardingSlide3Subtitle =>
      'Search, share, and export all your\npast transcriptions with ease.';

  @override
  String get alertsComingSoon => 'Alerts — coming soon';

  @override
  String get jobDetailTitle => 'Job Detail';

  @override
  String get jobDetailTranscriptionComplete => 'Transcription Complete';

  @override
  String get jobDetailTranscript => 'Transcript';

  @override
  String get jobDetailTranscriptPending => 'The transcript isn\'t ready yet.';

  @override
  String get jobDetailAiSummary => 'AI Summary';

  @override
  String get jobDetailSummaryPending => 'The summary isn\'t ready yet.';

  @override
  String get jobDetailDownloadTranscript => 'Download Transcript';

  @override
  String get jobDetailShare => 'Share';

  @override
  String get jobDetailCopyText => 'Copy Text';

  @override
  String get jobDetailKeyTakeaways => 'KEY TAKEAWAYS';

  @override
  String jobDetailWordCount(int count) {
    return '$count words';
  }

  @override
  String get jobDetailCancelJob => 'Cancel Job';

  @override
  String get jobDetailCancelling => 'Cancelling…';

  @override
  String get jobDetailReconnecting => 'Reconnecting…';

  @override
  String get jobDetailJustNow => 'Just now';

  @override
  String jobDetailMinutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String jobDetailHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String jobDetailDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get jobDetailShowMore => 'Show more';

  @override
  String get jobDetailShowLess => 'Show less';

  @override
  String get profileComingSoon => 'Profile — coming soon';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileModels => 'Speech models';

  @override
  String get modelsScreenTitle => 'Speech Models';

  @override
  String get modelsTierBase => 'Base';

  @override
  String get modelsTierBaseDescription => 'Fastest, lowest storage use';

  @override
  String get modelsTierSmall => 'Small';

  @override
  String get modelsTierSmallDescription =>
      'Recommended — balanced accuracy and size';

  @override
  String get modelsTierMedium => 'Medium';

  @override
  String get modelsTierMediumDescription => 'Best accuracy, largest download';

  @override
  String get modelsDefaultBadge => 'Default';

  @override
  String get modelsInstalled => 'Installed';

  @override
  String get modelsNotInstalled => 'Not downloaded';

  @override
  String get modelsDownload => 'Download';

  @override
  String get modelsDelete => 'Delete';

  @override
  String get modelsCancelDownload => 'Cancel';

  @override
  String modelsDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String modelsSizeMb(String size) {
    return '$size MB';
  }

  @override
  String modelsSizeGb(String size) {
    return '$size GB';
  }

  @override
  String get modelsSectionAsr => 'Speech-to-text';

  @override
  String get modelsSectionSummarization => 'Summarization';

  @override
  String get modelsTierGemma1b => 'Gemma 3 1B';

  @override
  String get modelsTierGemma1bDescription =>
      'Fast, on-device summaries — recommended';

  @override
  String get modelsTierGemma4b => 'Gemma 3 4B';

  @override
  String get modelsTierGemma4bDescription =>
      'Higher-quality summaries, larger download';

  @override
  String modelsRamGateBlocked(String gbRequired) {
    return 'Requires a device with at least $gbRequired GB of RAM';
  }

  @override
  String modelsRamUnknownWarning(String gbRequired) {
    return 'Could not verify available device memory — this model needs $gbRequired GB of RAM to run smoothly';
  }

  @override
  String get summarizeScreenTitle => 'Summarize';

  @override
  String get summarizeTranscriptHint => 'Paste or type the transcript here';

  @override
  String get summarizeLengthShort => 'Short';

  @override
  String get summarizeLengthMedium => 'Medium';

  @override
  String get summarizeLengthDetailed => 'Detailed';

  @override
  String get summarizeAction => 'Summarize';

  @override
  String get summarizeCancel => 'Cancel';

  @override
  String get summarizeNewSummary => 'New summary';

  @override
  String get summarizeStagePreparing => 'Preparing transcript';

  @override
  String get summarizeStageAnalyzing => 'Analyzing transcript';

  @override
  String get summarizeStageSummarizing => 'Summarizing sections';

  @override
  String get summarizeStageCombining => 'Combining information';

  @override
  String get summarizeStageChecking => 'Checking summary';

  @override
  String get summarizeStageFinalizing => 'Finalizing';

  @override
  String get summarizeStageCompleted => 'Completed';

  @override
  String summarizeChunkProgress(int processed, int total) {
    return '$processed of $total sections';
  }

  @override
  String get summarizeResultTitle => 'Summary';

  @override
  String get summarizeKeyPoints => 'Key points';

  @override
  String get summarizeImportantFacts => 'Important facts';

  @override
  String get summarizeCheckWarning =>
      'Some details in this summary could not be verified against the transcript. Please review it.';

  @override
  String get summarizeCancelled => 'Summarization was cancelled.';

  @override
  String get summarizeErrorEmpty => 'There is no transcript text to summarize.';

  @override
  String get summarizeErrorModel =>
      'The on-device summarization model isn\'t available.';

  @override
  String get summarizeErrorGeneration =>
      'The summary could not be generated. Please try again.';

  @override
  String get profileSummarize => 'Summarize text';

  @override
  String get newJobSourceUnavailable =>
      'Only pasted text can be summarized on this device for now. Audio, video and YouTube sources aren\'t available yet.';

  @override
  String get jobDetailSummaryComplete => 'Summary Complete';
}
