import 'package:flutter/foundation.dart';

/// Structured information extracted from one chunk.
@immutable
class ChunkAnalysis {
  const ChunkAnalysis({
    required this.chunkId,
    this.main = '',
    this.points = const [],
    this.facts = const [],
    this.importantTerms = const [],
    this.usedFallback = false,
  });

  final int chunkId;
  final String main;
  final List<String> points;
  final List<String> facts;
  final List<String> importantTerms;

  /// True when the model response had no recognisable headings and the whole
  /// response was kept as [main].
  final bool usedFallback;

  bool get isEmpty =>
      main.isEmpty && points.isEmpty && facts.isEmpty && importantTerms.isEmpty;
}
