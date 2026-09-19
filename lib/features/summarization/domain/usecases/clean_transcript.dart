import 'package:nutq/features/summarization/domain/text/transcript_cleaner.dart';

class CleanTranscript {
  const CleanTranscript([this._cleaner = const TranscriptCleaner()]);

  final TranscriptCleaner _cleaner;

  String call(String raw) => _cleaner.clean(raw);
}
