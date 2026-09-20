import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';
import 'package:nutq/features/summarization/domain/usecases/clean_transcript.dart';

/// A cleaned transcript and its sentences.
typedef PreparedTranscript = ({String cleaned, List<Sentence> sentences});

/// Arguments for [prepareTranscript]; plain data so it can cross isolates.
typedef PrepareRequest = ({CleanTranscript clean, int maxSentenceWords, String text});

/// Cleans and segments a raw transcript. Pure and CPU-bound, so it is a
/// top-level function that a `BackgroundWork` can run off the UI thread.
PreparedTranscript prepareTranscript(PrepareRequest request) {
  final cleaned = request.clean(request.text);
  final sentences = SentenceSegmenter(maxWords: request.maxSentenceWords).segment(cleaned);
  return (cleaned: cleaned, sentences: sentences);
}
