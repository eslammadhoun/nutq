import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source.dart';

/// The sources the app can process. Registering a [TranscriptSource] is what
/// makes a source type usable: the New Job sheet enables exactly
/// [supportedTypes], and the processor looks sources up here.
class TranscriptSourceRegistry {
  TranscriptSourceRegistry(Iterable<TranscriptSource> sources)
    : _byType = {for (final s in sources) s.type: s};

  final Map<JobSourceType, TranscriptSource> _byType;

  Set<JobSourceType> get supportedTypes => Set.unmodifiable(_byType.keys);

  bool supports(JobSourceType type) => _byType.containsKey(type);

  TranscriptSource? of(JobSourceType type) => _byType[type];
}
