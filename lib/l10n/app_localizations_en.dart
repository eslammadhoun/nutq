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
  String get errorInvalidCredentials => 'Invalid credentials';

  @override
  String get errorLoginAgain => 'Please log in again';

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
  String get newJobFileNameLabel => 'Filename (optional)';

  @override
  String get newJobFileNameHint => 'e.g. interview-2026-08-09.mp3';

  @override
  String get newJobYoutubeUrlLabel => 'YouTube URL';

  @override
  String get newJobYoutubeUrlHint => 'https://youtube.com/watch?v=...';

  @override
  String get newJobForceWhisper => 'Force Whisper';

  @override
  String get newJobForceWhisperSubtitle =>
      'Bypass auto-detection, use Whisper model';

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
  String get profileComingSoon => 'Profile — coming soon';

  @override
  String get profileLogOut => 'Log out';
}
