/// Requested size of the final summary. Targets are starting points, not
/// hard limits: coverage takes priority over hitting an exact word count.
enum SummaryLength {
  short(minWords: 120, maxWords: 180),
  medium(minWords: 250, maxWords: 400),
  detailed(minWords: 500, maxWords: 700);

  const SummaryLength({required this.minWords, required this.maxWords});

  final int minWords;
  final int maxWords;
}
