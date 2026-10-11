import 'package:flutter/foundation.dart';
import 'package:nutq/features/jobs/domain/entities/job_stage.dart';

/// Where a running job is, for the progress UI.
@immutable
class JobProgress {
  const JobProgress(this.stage, {required this.fraction, this.done, this.total});

  final JobStage stage;

  /// Overall completion of the whole job, 0.0–1.0. Composed by the processor
  /// so it stays monotonic across acquiring, transcribing and summarizing.
  final double fraction;

  /// Items processed of [total] (for example sections), when known.
  final int? done;
  final int? total;

  @override
  bool operator ==(Object other) =>
      other is JobProgress &&
      other.stage == stage &&
      other.fraction == fraction &&
      other.done == done &&
      other.total == total;

  @override
  int get hashCode => Object.hash(stage, fraction, done, total);
}
