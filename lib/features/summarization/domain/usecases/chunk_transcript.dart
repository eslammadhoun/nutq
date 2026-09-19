import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/semantic_chunker.dart';
import 'package:nutq/features/summarization/domain/text/sentence_segmenter.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Cleaned transcript → sentences → chunks.
class ChunkTranscript {
  const ChunkTranscript();

  /// Returns the sentences too: validation and evidence selection need them.
  Future<({List<Sentence> sentences, List<TranscriptChunk> chunks})> call(
    String cleanedTranscript,
    SummarizationConfig config,
    TokenCounter counter,
  ) async {
    final sentences = SentenceSegmenter(
      maxWords: config.maxSentenceWords,
    ).segment(cleanedTranscript);
    final chunks = await SemanticChunker(counter).chunk(sentences, config);
    return (sentences: sentences, chunks: chunks);
  }
}
