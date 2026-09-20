import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';

/// What the jobs list wants to see. Newest jobs first.
@immutable
class JobsQuery {
  const JobsQuery({this.statuses, this.text = '', this.limit = defaultLimit});

  static const defaultLimit = 30;

  /// Only jobs in these states; null means every state.
  final Set<JobRunStatus>? statuses;

  /// Matches the job's preview or transcript text; blank means no text filter.
  final String text;

  /// Maximum number of rows. Grows as the user scrolls.
  final int limit;

  JobsQuery copyWith({
    Set<JobRunStatus>? statuses,
    bool clearStatuses = false,
    String? text,
    int? limit,
  }) => JobsQuery(
    statuses: clearStatuses ? null : (statuses ?? this.statuses),
    text: text ?? this.text,
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is JobsQuery &&
      other.text == text &&
      other.limit == limit &&
      setEquals(other.statuses, statuses);

  @override
  int get hashCode => Object.hash(text, limit, Object.hashAllUnordered(statuses ?? const {}));
}
