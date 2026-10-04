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
  String get validationPasswordLowercase => 'Password must contain at least one lowercase letter';

  @override
  String get validationPasswordUppercase => 'Password must contain at least one uppercase letter';

  @override
  String get validationPasswordNumber => 'Password must contain at least one number';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get validationNameChars =>
      'Name can only contain letters, spaces, hyphens, and apostrophes';

  @override
  String get validationUsernameChars =>
      'Username can only contain letters, numbers, underscores, and hyphens';

  @override
  String get jobsHistoryTitle => 'History';

  @override
  String get jobsSearchHint => 'Search transcriptions...';

  @override
  String get jobsFilterAll => 'All';

  @override
  String get jobsEmptyTitle => 'No transcriptions yet';

  @override
  String get jobsEmptySubtitle => 'Submit your first Arabic audio, video, \nor text to get started';

  @override
  String get sourceAudioFile => 'Audio File';

  @override
  String get sourceVideo => 'Video';

  @override
  String get sourceYoutube => 'YouTube';

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
  String get newJobTextLabel => 'Enter or paste your Arabic text';

  @override
  String get newJobTextPlaceholder => 'Example: enter Arabic text here to get a summary...';

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
  String get jobDetailTranscriptLive => 'Live';

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
  String get jobStagePreparing => 'Preparing transcript';

  @override
  String get jobStageAnalyzing => 'Analyzing transcript';

  @override
  String get jobStageSummarizing => 'Summarizing sections';

  @override
  String get jobStageCombining => 'Combining information';

  @override
  String get jobStageChecking => 'Checking summary';

  @override
  String get jobStageFinalizing => 'Finalizing';

  @override
  String get jobStageCompleted => 'Completed';

  @override
  String jobStageSections(int processed, int total) {
    return '$processed of $total sections';
  }

  @override
  String get jobSummaryNeedsReview =>
      'Some details in this summary could not be verified against the transcript. Please review it.';

  @override
  String get jobFailureEmptyTranscript => 'There is no transcript text to summarize.';

  @override
  String get jobFailureModelUnavailable => 'The on-device summarization model isn\'t available.';

  @override
  String get jobFailureGenerationFailed => 'The summary could not be generated. Please try again.';

  @override
  String get newJobSourceUnavailable =>
      'Only pasted text can be summarized on this device for now. Audio, video and YouTube sources aren\'t available yet.';

  @override
  String get jobDetailSummaryComplete => 'Summary Complete';

  @override
  String get errorStorage => 'Couldn\'t access saved jobs on this device. Please try again.';

  @override
  String get jobDetailNotFound => 'This job no longer exists.';

  @override
  String get jobFailureInterrupted =>
      'This job was interrupted because the app was closed before it finished.';

  @override
  String get jobStageAcquiring => 'Fetching source';

  @override
  String get jobStageTranscribing => 'Transcribing audio';

  @override
  String get jobFailureSourceUnavailable =>
      'The source couldn\'t be reached. Check your connection and try again.';

  @override
  String get jobFailureUnsupportedMedia => 'This file\'s format isn\'t supported.';

  @override
  String get jobFailureTranscriptionFailed => 'The audio couldn\'t be transcribed.';

  @override
  String get jobFailureInsufficientStorage =>
      'There isn\'t enough free storage to process this job.';

  @override
  String backgroundJobTranscribing(String percent) {
    return 'Transcribing · $percent';
  }

  @override
  String backgroundJobPaused(String percent) {
    return 'Paused · $percent';
  }

  @override
  String backgroundJobInterruptedTitle(String percent) {
    return 'Transcription paused at $percent';
  }

  @override
  String backgroundJobInterruptedBody(String title) {
    return 'Another app is playing audio. Open Nutq to continue $title.';
  }

  @override
  String get backgroundJobReadyTitle => 'Transcript ready';

  @override
  String backgroundJobReadyBody(String title) {
    return 'Open Nutq to summarize $title.';
  }

  @override
  String backgroundJobSummarizing(String percent) {
    return 'Summarizing · $percent';
  }

  @override
  String backgroundJobWaitingForApp(String percent) {
    return 'Open Nutq to summarize · $percent';
  }

  @override
  String get backgroundJobDoneTitle => 'Summary ready';

  @override
  String backgroundJobDoneBody(String title) {
    return '$title is summarized.';
  }
}
