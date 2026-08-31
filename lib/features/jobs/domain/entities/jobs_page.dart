import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';

part 'jobs_page.freezed.dart';

/// Domain equivalent of [JobListResponse].
@freezed
sealed class JobsPage with _$JobsPage {
  const factory JobsPage({
    required List<JobEntity> items,
    String? nextCursor,
  }) = _JobsPage;
}
