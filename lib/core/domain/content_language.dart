/// Language of a piece of text: a job's source transcript or its generated
/// summary. Shared by the jobs and summarization features.
enum ContentLanguage {
  ar('ar', 'Arabic'),
  en('en', 'English');

  const ContentLanguage(this.code, this.promptName);

  final String code;

  /// Name used inside model prompts.
  final String promptName;

  static ContentLanguage fromCode(String code) =>
      values.firstWhere((l) => l.code == code, orElse: () => ContentLanguage.ar);
}
