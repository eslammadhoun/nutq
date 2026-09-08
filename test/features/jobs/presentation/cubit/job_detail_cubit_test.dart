import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_detail_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_entity.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';
import 'package:nutq/features/jobs/domain/entities/jobs_page.dart';
import 'package:nutq/features/jobs/domain/entities/submit_job_params.dart';
import 'package:nutq/features/jobs/domain/entities/transcript.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_state.dart';

JobDetailEntity _jobDetail({String status = 'completed', Transcript? transcript}) =>
    JobDetailEntity(
      id: 'job-1',
      status: status,
      sourceType: 'upload',
      language: 'ar',
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
      transcript: transcript,
    );

class _FakeJobsRepository implements JobsRepository {
  _FakeJobsRepository({
    this.getJobResult,
    this.cancelJobResult,
    this.transcriptTextResult,
  });

  ApiResult<JobDetailEntity>? getJobResult;
  ApiResult<JobEntity>? cancelJobResult;
  final List<String> cancelledJobIds = [];
  int getJobCallCount = 0;

  @override
  Future<ApiResult<JobDetailEntity>> getJob(String jobId) async {
    getJobCallCount++;
    return getJobResult ?? ApiResult.success(_jobDetail());
  }

  @override
  Future<ApiResult<JobEntity>> cancelJob(String jobId) async {
    cancelledJobIds.add(jobId);
    return cancelJobResult ??
        ApiResult.success(
          JobEntity(
            id: jobId,
            status: 'cancelled',
            sourceType: 'upload',
            language: 'ar',
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
  }

  @override
  Future<ApiResult<JobsPage>> listJobs({String? cursor, int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> submitJob(SubmitJobParams params) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<JobEntity>> confirmUpload(String jobId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> uploadToSlot(String uploadUrl, UploadFile file) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> deleteJob(String jobId) => throw UnimplementedError();

  ApiResult<String>? transcriptTextResult;
  final List<String> fetchedTranscriptUrls = [];

  @override
  Future<ApiResult<String>> fetchTranscriptText(String downloadUrl) async {
    fetchedTranscriptUrls.add(downloadUrl);
    return transcriptTextResult ?? const ApiResult.success('');
  }
}

/// Fakes the socket transport — broadcast controllers the test drives
/// directly, following the same "fake the interface, canned result"
/// convention as [_FakeJobsRepository].
class _FakeJobUpdatesSocketService implements JobUpdatesSocketService {
  final _eventsController = StreamController<JobUpdateEvent>.broadcast();
  final _statusController = StreamController<JobConnectionStatus>.broadcast();

  String? lastConnectedJobId;
  int connectCallCount = 0;
  int disconnectCallCount = 0;

  @override
  Stream<JobUpdateEvent> connect(String jobId) {
    lastConnectedJobId = jobId;
    connectCallCount++;
    return _eventsController.stream;
  }

  @override
  Stream<JobConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  void disconnect() {
    disconnectCallCount++;
  }

  void emitEvent(JobUpdateEvent event) => _eventsController.add(event);

  void emitStatus(JobConnectionStatus status) => _statusController.add(status);

  Future<void> dispose() async {
    await _eventsController.close();
    await _statusController.close();
  }
}

void main() {
  group('JobDetailCubit', () {
    test('fetches the job on creation and emits success', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'completed')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, JobDetailStatus.success);
      expect(cubit.state.job?.id, 'job-1');
      await cubit.close();
      await socket.dispose();
    });

    test('opens the socket for the job after the first successful fetch', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      expect(socket.lastConnectedJobId, 'job-1');
      expect(socket.connectCallCount, 1);
      await cubit.close();
      await socket.dispose();
    });

    test('fetches and caches the transcript body when a downloadUrl exists', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(
          _jobDetail(
            transcript: const Transcript(
              language: 'ar',
              modelName: 'Inter Model',
              modelVersion: '3.1',
              downloadUrl: 'https://example.com/transcript.txt',
            ),
          ),
        ),
        transcriptTextResult: const ApiResult.success('Hello world'),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      expect(repo.fetchedTranscriptUrls, ['https://example.com/transcript.txt']);
      expect(cubit.state.transcriptText, 'Hello world');
      expect(cubit.state.isLoadingTranscriptText, isFalse);
      await cubit.close();
      await socket.dispose();
    });

    test(
      'uses the inlined transcript text directly, skipping the downloadUrl fetch '
      'entirely (the REST/WS body now inlines the text)',
      () async {
        final repo = _FakeJobsRepository(
          getJobResult: ApiResult.success(
            _jobDetail(
              transcript: const Transcript(
                language: 'ar',
                modelName: 'Inter Model',
                modelVersion: '3.1',
                downloadUrl: 'https://example.com/transcript.txt',
                text: 'Inlined transcript body.',
              ),
            ),
          ),
        );
        final socket = _FakeJobUpdatesSocketService();
        final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
        await Future<void>.delayed(Duration.zero);

        expect(repo.fetchedTranscriptUrls, isEmpty);
        expect(cubit.state.transcriptText, 'Inlined transcript body.');
        await cubit.close();
        await socket.dispose();
      },
    );

    test('does not fetch a transcript body when there is no downloadUrl', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(
          _jobDetail(
            transcript: const Transcript(
              language: 'ar',
              modelName: 'Inter Model',
              modelVersion: '3.1',
            ),
          ),
        ),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      expect(repo.fetchedTranscriptUrls, isEmpty);
      expect(cubit.state.transcriptText, isNull);
      await cubit.close();
      await socket.dispose();
    });

    test('emits failure carrying the raw ApiError', () async {
      final repo = _FakeJobsRepository(
        getJobResult: const ApiResult.failure(ApiError.network()),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, JobDetailStatus.failure);
      expect(cubit.state.lastError, const ApiError.network());
      await cubit.close();
      await socket.dispose();
    });

    test('cancelJob forwards the id and refreshes on success', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      await cubit.cancelJob();

      expect(repo.cancelledJobIds, ['job-1']);
      expect(cubit.state.isCancelling, isFalse);
      expect(cubit.state.cancelError, isNull);
      await cubit.close();
      await socket.dispose();
    });

    test('cancelJob surfaces the error and clears isCancelling on failure', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'queued')),
        cancelJobResult: const ApiResult.failure(ApiError.network()),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      await cubit.cancelJob();

      expect(cubit.state.isCancelling, isFalse);
      expect(cubit.state.cancelError, const ApiError.network());
      expect(cubit.state.cancelErrorToken, 1);
      await cubit.close();
      await socket.dispose();
    });

    test('cancelJob is a no-op before the job has loaded', () async {
      final repo = _FakeJobsRepository(
        getJobResult: const ApiResult.failure(ApiError.network()),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      await cubit.cancelJob();

      expect(repo.cancelledJobIds, isEmpty);
      await cubit.close();
      await socket.dispose();
    });

    test('a snapshot event overwrites job state wholesale', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'queued')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      socket.emitEvent(JobUpdateEvent.snapshot(job: _jobDetail(status: 'processing')));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, JobDetailStatus.success);
      expect(cubit.state.job?.status, 'processing');
      await cubit.close();
      await socket.dispose();
    });

    test('transcript/summary words append incrementally in order', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 0, word: 'Hello'));
      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 1, word: 'world'));
      socket.emitEvent(const JobUpdateEvent.summaryWord(index: 0, word: 'Short'));
      socket.emitEvent(const JobUpdateEvent.summaryWord(index: 1, word: 'summary'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.streamingTranscript, 'Hello world');
      expect(cubit.state.streamingSummary, 'Short summary');
      await cubit.close();
      await socket.dispose();
    });

    test('a replayed (already-applied) word index is dropped, not duplicated', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 0, word: 'Hello'));
      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 1, word: 'world'));
      // Reconnect replay — the server resends the same indices from the
      // start of its Redis-backed stream.
      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 0, word: 'Hello'));
      socket.emitEvent(const JobUpdateEvent.transcriptWord(index: 1, word: 'world'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.streamingTranscript, 'Hello world');
      await cubit.close();
      await socket.dispose();
    });

    test('a done event finalizes state and tears down the socket', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      socket.emitEvent(JobUpdateEvent.done(job: _jobDetail(status: 'completed')));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, JobDetailStatus.success);
      expect(cubit.state.job?.status, 'completed');
      expect(socket.disconnectCallCount, 1);
      await cubit.close();
      await socket.dispose();
    });

    test(
      'a snapshot for an already-completed job populates transcript/summary '
      'text from the inlined payload, not just job state',
      () async {
        final repo = _FakeJobsRepository(
          getJobResult: ApiResult.success(_jobDetail(status: 'completed')),
        );
        final socket = _FakeJobUpdatesSocketService();
        final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
        await Future<void>.delayed(Duration.zero);

        socket.emitEvent(
          JobUpdateEvent.snapshot(
            job: _jobDetail(status: 'completed'),
            transcriptText: 'Full transcript body.',
            summaryText: 'Full summary body.',
            summaryTakeaways: [
              {'text': 'Key point'},
            ],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.streamingTranscript, 'Full transcript body.');
        expect(cubit.state.streamingSummary, 'Full summary body.');
        expect(cubit.state.summaryTakeaways, [
          {'text': 'Key point'},
        ]);
        await cubit.close();
        await socket.dispose();
      },
    );

    test(
      'a done event for an already-completed job populates transcript/summary '
      'text from the inlined payload (the historical-job "not ready" regression)',
      () async {
        final repo = _FakeJobsRepository(
          getJobResult: ApiResult.success(_jobDetail(status: 'completed')),
        );
        final socket = _FakeJobUpdatesSocketService();
        final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
        await Future<void>.delayed(Duration.zero);

        socket.emitEvent(
          JobUpdateEvent.done(
            job: _jobDetail(status: 'completed'),
            transcriptText: 'Final transcript body.',
            summaryText: 'Final summary body.',
            summaryTakeaways: const [],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.streamingTranscript, 'Final transcript body.');
        expect(cubit.state.streamingSummary, 'Final summary body.');
        await cubit.close();
        await socket.dispose();
      },
    );

    test('an error event surfaces as ApiError.server(404) for a 4404 close and tears down '
        'the socket', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);

      socket.emitEvent(const JobUpdateEvent.error(message: 'not_found', code: '4404'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, JobDetailStatus.failure);
      expect(cubit.state.lastError, const ApiError.server('not_found', 404));
      expect(socket.disconnectCallCount, 1);
      await cubit.close();
      await socket.dispose();
    });

    test('connectionStatus.disconnected engages the polling fallback', () {
      fakeAsync((async) {
        final repo = _FakeJobsRepository(
          getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
        );
        final socket = _FakeJobUpdatesSocketService();
        final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
        async.flushMicrotasks();

        expect(repo.getJobCallCount, 1);

        socket.emitStatus(JobConnectionStatus.disconnected);
        async.flushMicrotasks();
        expect(cubit.state.connectionStatus, JobConnectionStatus.disconnected);

        // Polling fallback should now be ticking every 3s.
        async.elapse(const Duration(seconds: 3));
        expect(repo.getJobCallCount, 2);

        unawaited(cubit.close());
        unawaited(socket.dispose());
      });
    });

    test('refresh() re-attempts the socket while in fallback mode', () async {
      final repo = _FakeJobsRepository(
        getJobResult: ApiResult.success(_jobDetail(status: 'processing')),
      );
      final socket = _FakeJobUpdatesSocketService();
      final cubit = JobDetailCubit(repo: repo, jobId: 'job-1', socketService: socket);
      await Future<void>.delayed(Duration.zero);
      expect(socket.connectCallCount, 1);

      socket.emitStatus(JobConnectionStatus.disconnected);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.connectionStatus, JobConnectionStatus.disconnected);

      await cubit.refresh();

      expect(socket.connectCallCount, 2);
      await cubit.close();
      await socket.dispose();
    });
  });
}
