import 'package:nutq/features/summarization/domain/entities/sentence.dart';
import 'package:nutq/features/summarization/domain/entities/summarization_config.dart';
import 'package:nutq/features/summarization/domain/entities/transcript_chunk.dart';
import 'package:nutq/features/summarization/domain/text/semantic_chunker.dart';
import 'package:nutq/features/summarization/domain/text/token_counter.dart';

/// Sentences → token-budgeted chunks (needs the model's tokenizer, so it runs
/// on the main isolate; the sentence splitting before it does not).
class ChunkTranscript {
  const ChunkTranscript();

  Future<List<TranscriptChunk>> call(
    List<Sentence> sentences,
    SummarizationConfig config,
    TokenCounter counter,
  ) => SemanticChunker(counter).chunk(sentences, config);
}
