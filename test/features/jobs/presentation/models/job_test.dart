import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/presentation/models/job.dart';

JobEntity _entity({
  String status = 'completed',
  String sourceType = 'text',
  String? errorDetail,
  String? preview,
  String? contentType,
}) => JobEntity(
  id: 'job-1',
  status: status,
  sourceType: sourceType,
  language: 'ar',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
  errorDetail: errorDetail,
  preview: preview,
  contentType: contentType,
);

void main() {
  group('Job.fromEntity', () {
    test('carries the server-provided preview through to the UI model', () {
      final job = Job.fromEntity(_entity(preview: 'Hello and welcome to...'));
      expect(job.preview, 'Hello and welcome to...');
    });

    test('preview is null when the entity has none', () {
      final job = Job.fromEntity(_entity());
      expect(job.preview, isNull);
    });

    test('failed jobs still surface the server error as subtitle', () {
      final job = Job.fromEntity(
        _entity(status: 'failed', errorDetail: 'Audio too short'),
      );
      expect(job.subtitle, 'Audio too short');
      expect(job.status, JobStatus.failed);
    });

    test('maps known status/source strings', () {
      expect(Job.fromEntity(_entity(status: 'completed')).status, JobStatus.done);
      expect(Job.fromEntity(_entity(status: 'pending')).status, JobStatus.queued);
      expect(Job.fromEntity(_entity(status: 'cancelled')).status, JobStatus.cancelled);
      expect(
        Job.fromEntity(_entity(status: 'transcribing')).status,
        JobStatus.processing,
      );
      expect(
        Job.fromEntity(_entity(sourceType: 'youtube')).sourceType,
        JobSourceType.youtube,
      );
      expect(
        Job.fromEntity(_entity(sourceType: 'unknown-type')).sourceType,
        JobSourceType.text,
      );
    });
  });

  group('Job.isVideoUpload', () {
    test('true for an upload job with a video content_type', () {
      final job = Job.fromEntity(
        _entity(sourceType: 'upload', contentType: 'video/mp4'),
      );
      expect(job.isVideoUpload, isTrue);
    });

    test('false for an upload job with an audio content_type', () {
      final job = Job.fromEntity(
        _entity(sourceType: 'upload', contentType: 'audio/mpeg'),
      );
      expect(job.isVideoUpload, isFalse);
    });

    test('null for an upload job with no content_type (legacy job)', () {
      final job = Job.fromEntity(_entity(sourceType: 'upload'));
      expect(job.isVideoUpload, isNull);
    });

    test('null for a non-upload job even if content_type is set', () {
      final job = Job.fromEntity(
        _entity(sourceType: 'text', contentType: 'video/mp4'),
      );
      expect(job.isVideoUpload, isNull);
    });
  });
}
