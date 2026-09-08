import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/summary.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';

part 'job_detail_entity.freezed.dart';

/// Domain job detail — backed by a `Jobs` DB row joined with its optional
/// `Transcripts`/`Summaries`/`Takeaways` rows.
@freezed
sealed class JobDetailEntity with _$JobDetailEntity {
  const factory JobDetailEntity({
    required String id,
    required String status,
    required String sourceType,
    required String language,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? errorCode,
    String? errorDetail,
    String? contentType,
    Transcript? transcript,
    Summary? summary,
    // Progress fields with no local processing pipeline yet (Workstream 5)
    // to populate them — left null/default until then.
    bool? isTerminal,
    int? stageIndex,
    int? stageTotal,
    List<String>? stages,
    double? progress,
  }) = _JobDetailEntity;
}
