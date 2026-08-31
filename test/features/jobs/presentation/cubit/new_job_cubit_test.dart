import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/datasources/file_picker_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/entities/upload_slot.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

const _audioFile = UploadFile(
  name: 'lecture.mp3',
  path: '/tmp/lecture.mp3',
  sizeBytes: 2048,
  contentType: 'audio/mpeg',
);

JobEntity _job(String id, {UploadSlot? slot}) => JobEntity(
  id: id,
  status: 'pending',
  sourceType: 'upload',
  language: 'ar',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
  uploadSlot: slot,
);

class _FakeJobsRepository implements JobsRepository {
  _FakeJobsRepository({this.submitResults});

  final List<ApiResult<JobEntity>>? submitResults;

  final List<SubmitJobParams> requests = [];
  final List<(String, UploadFile)> uploadedSlots = [];
  final List<String> confirmedJobIds = [];
  int submitCalls = 0;
  int uploadCalls = 0;

  @override
  Future<ApiResult<JobsPage>> listJobs({
    String? cursor,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params) async {
    submitCalls++;
    requests.add(params);
    final results = submitResults;
    if (results == null || results.isEmpty) throw UnimplementedError();
    return results.removeAt(0);
  }

  @override
  Future<ApiResult<JobDetailEntity>> getJob(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> cancelJob(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> confirmUpload(String jobId) async {
    confirmedJobIds.add(jobId);
    return ApiResult.success(_job(jobId));
  }

  @override
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file) async {
    uploadCalls++;
    uploadedSlots.add((uploadUrl, file));
    return const ApiResult.success(null);
  }
}

class _FakeFilePicker implements FilePickerService {
  _FakeFilePicker({this.file});

  final UploadFile? file;

  @override
  Future<UploadFile?> pick({required PickableMedia media}) async => file;
}

NewJobCubit _buildCubit(
  _FakeJobsRepository repo, {
  UploadFile? pickedFile,
}) {
  int keyCounter = 0;
  return NewJobCubit(
    repository: repo,
    filePicker: _FakeFilePicker(file: pickedFile),
    generateIdempotencyKey: () => 'generated-key-${++keyCounter}',
  );
}

void main() {
  group('NewJobCubit', () {
    test('text job submits source_type=text and skips the upload flow', () async {
      final repo = _FakeJobsRepository(
        submitResults: [ApiResult.success(_job('job-1'))],
      );
      final cubit = _buildCubit(repo);

      cubit.setText('مرحبا بالعالم');
      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.success);
      expect(cubit.state.submittedJobId, 'job-1');
      expect(repo.requests.single.sourceType, 'text');
      expect(repo.requests.single.text, 'مرحبا بالعالم');
      expect(repo.requests.single.language, 'ar');
      expect(repo.requests.single.idempotencyKey, isNull);
      expect(repo.uploadedSlots, isEmpty);
      expect(repo.confirmedJobIds, isEmpty);
      await cubit.close();
    });

    test('submit is blocked while the text tab input is empty', () async {
      final repo = _FakeJobsRepository();
      final cubit = _buildCubit(repo);

      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.idle);
      expect(repo.submitCalls, 0);
      await cubit.close();
    });

    test('youtube job requires a valid url before submitting', () async {
      final repo = _FakeJobsRepository(
        submitResults: [ApiResult.success(_job('job-yt'))],
      );
      final cubit = _buildCubit(repo);
      cubit.changeSourceType(NewJobSourceType.youtube.index);

      cubit.setSourceUrl('not-a-youtube-link');
      await cubit.submit();
      expect(repo.submitCalls, 0);

      cubit.setSourceUrl('https://youtube.com/watch?v=abc123');
      cubit.toggleForceWhisper();
      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.success);
      final request = repo.requests.single;
      expect(request.sourceType, 'youtube');
      expect(request.sourceUrl, 'https://youtube.com/watch?v=abc123');
      expect(request.forceWhisper, isTrue);
      await cubit.close();
    });

    test('audio job uploads to slot then confirms with the created job id',
        () async {
      final repo = _FakeJobsRepository(
        submitResults: [
          ApiResult.success(
            _job(
              'job-up',
              slot: const UploadSlot(
                uploadUrl: '/v1/dev-storage/token123',
                uploadToken: 'token123',
                expiresInSeconds: 300,
              ),
            ),
          ),
        ],
      );
      final cubit = _buildCubit(repo, pickedFile: _audioFile);

      cubit.changeSourceType(NewJobSourceType.audio.index);
      await cubit.pickMedia();
      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.success);
      final request = repo.requests.single;
      expect(request.sourceType, 'upload');
      expect(request.filename, 'lecture.mp3');
      expect(request.contentType, 'audio/mpeg');
      expect(request.sizeHint, 2048);

      final (url, file) = repo.uploadedSlots.single;
      expect(url, '/v1/dev-storage/token123');
      expect(file.name, 'lecture.mp3');
      expect(repo.confirmedJobIds, ['job-up']);
      await cubit.close();
    });

    test('filename override wins over the picked file name', () async {
      final repo = _FakeJobsRepository(
        submitResults: [ApiResult.success(_job('job-up2'))],
      );
      final cubit = _buildCubit(repo, pickedFile: _audioFile);

      cubit.changeSourceType(NewJobSourceType.audio.index);
      await cubit.pickMedia();
      cubit.setFilename('interview-final.mp3');
      await cubit.submit();

      expect(repo.requests.single.filename, 'interview-final.mp3');
      expect(repo.uploadedSlots, isEmpty);
      await cubit.close();
    });

    test('failure carries the raw ApiError and keeps state submittable',
        () async {
      final repo = _FakeJobsRepository(
        submitResults: [const ApiResult.failure(ApiError.network())],
      );
      final cubit = _buildCubit(repo);

      cubit.setText('نص عربي');
      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.failure);
      expect(cubit.state.lastError, const ApiError.network());
      expect(cubit.state.canSubmit, isTrue);
      await cubit.close();
    });

    test('idempotency key is generated once and stable across retries',
        () async {
      final repo = _FakeJobsRepository(
        submitResults: [
          const ApiResult.failure(ApiError.server('boom', 500)),
          ApiResult.success(_job('job-retry')),
          ApiResult.success(_job('job-retry-2')),
        ],
      );
      final cubit = _buildCubit(repo);

      cubit.setText('نص عربي');
      cubit.toggleIdempotency();
      await cubit.submit();
      await cubit.submit();

      expect(repo.requests.length, 2);
      expect(repo.requests[0].idempotencyKey, 'generated-key-1');
      expect(repo.requests[1].idempotencyKey, 'generated-key-1');

      cubit.toggleIdempotency();
      await cubit.submit();
      expect(repo.requests[2].idempotencyKey, isNull);
      await cubit.close();
    });

    test('oversized file flags fileTooLarge and disables submission',
        () async {
      final oversized = UploadFile(
        name: 'huge.wav',
        path: '/tmp/huge.wav',
        sizeBytes: UploadFile.maxBytes + 1,
        contentType: 'audio/wav',
      );
      final repo = _FakeJobsRepository();
      final cubit = _buildCubit(repo, pickedFile: oversized);

      cubit.changeSourceType(NewJobSourceType.audio.index);
      await cubit.pickMedia();

      expect(cubit.state.fileTooLarge, isTrue);
      expect(cubit.state.pickedFile, isNotNull);
      expect(cubit.state.canSubmit, isFalse);
      expect(repo.submitCalls, 0);
      await cubit.close();
    });
  });
}
