/// Language of the transcript and of the generated summary.
enum SummaryLanguage {
  ar('ar', 'Arabic'),
  en('en', 'English');

  const SummaryLanguage(this.code, this.promptName);

  final String code;

  /// Name used inside model prompts.
  final String promptName;

  static SummaryLanguage fromCode(String code) =>
      values.firstWhere((l) => l.code == code, orElse: () => SummaryLanguage.ar);
}
