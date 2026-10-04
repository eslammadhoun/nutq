/// Requested size of the summary, as a scale on the default summary ratio
/// (`SummarizationConfig.summaryRatio`): the summary shrinks relative to the
/// source as the source grows, whichever length is chosen.
enum SummaryLength {
  short(ratioScale: 0.6),
  medium(ratioScale: 1),
  detailed(ratioScale: 1.6);

  const SummaryLength({required this.ratioScale});

  final double ratioScale;
}
