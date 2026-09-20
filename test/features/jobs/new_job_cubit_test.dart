import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/domain/entities/job_run_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/entities/upload_file.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';
import 'package:nutq/core/domain/content_language.dart';

import 'support/faulty_jobs_local_data_source.dart';
import 'support/job_harness.dart';

class _RecordingScheduler implements JobScheduler {
  final enqueued = <String>[];

  @override
  void enqueue(String jobId) => enqueued.add(jobId);

  @override
  Future<void> cancel(String jobId) async {}

  @override
  Stream<JobLive?> watchLive(String jobId) => const Stream.empty();
}

void main() {
  late JobHarness h;
  late _RecordingScheduler scheduler;

  setUp(() {
    h = JobHarness();
    scheduler = _RecordingScheduler();
  });
  tearDown(() => h.dispose());

  /// A cubit that only records what gets queued, so nothing actually runs.
  NewJobCubit recording({Set<JobSourceType> supported = const {JobSourceType.text}}) {
    final cubit = NewJobCubit(SubmitJob(h.repo, scheduler), supportedSources: supported);
    addTearDown(cubit.close);
    return cubit;
  }

  const audio = UploadFile(name: 'talk.m4a', path: '/app/files/talk.m4a', sizeBytes: 1000, contentType: 'audio/mp4');

  group('what can be submitted', () {
    test('only a non-empty text source is valid by default', () {
      final cubit = recording();
      expect(cubit.state.canSubmit, isFalse);
      cubit.setText('   ');
      expect(cubit.state.canSubmit, isFalse);
      cubit.setText('نص للتلخيص');
      expect(cubit.state.canSubmit, isTrue);
    });

    test('a source type nobody can process is refused, whatever its input', () {
      final cubit = recording(); // text only
      cubit.changeSourceType(JobSourceType.youtube.index);
      cubit.setSourceUrl('https://www.youtube.com/watch?v=abcdefghijk');
      expect(cubit.state.isSourceSupported, isFalse);
      expect(cubit.state.canSubmit, isFalse);
    });

    test('registering more sources enables them, each with its own validation', () {
      final cubit = recording(supported: JobSourceType.values.toSet());

      cubit.changeSourceType(JobSourceType.youtube.index);
      expect(cubit.state.canSubmit, isFalse, reason: 'needs a URL');
      cubit.setSourceUrl('https://youtu.be/abc');
      expect(cubit.state.canSubmit, isTrue);

      cubit.changeSourceType(JobSourceType.audio.index);
      expect(cubit.state.canSubmit, isFalse, reason: 'needs a file');
      cubit.emit(cubit.state.copyWith(pickedFile: audio));
      expect(cubit.state.canSubmit, isTrue);
      cubit.emit(cubit.state.copyWith(fileTooLarge: true));
      expect(cubit.state.canSubmit, isFalse, reason: 'file too large');
    });

    test('the app registers exactly the sources it can process', () {
      expect(h.newJobCubit().state.supportedSources, {JobSourceType.text});
    });
  });

  group('submitting', () {
    test('saves the job, queues it, and reports its id', () async {
      final cubit = recording()..setText('  نص للتلخيص  ');
      await cubit.submit();

      expect(cubit.state.status, NewJobStatus.success);
      final id = cubit.state.submittedJobId!;
      expect(scheduler.enqueued, [id]);
      final stored = (await h.repo.getJob(id))!;
      expect(stored.status, JobRunStatus.pending, reason: 'stored before it runs');
      expect(stored.transcript!.text, 'نص للتلخيص');
      expect(stored.sourceLanguage, ContentLanguage.ar);
      expect(stored.summaryLanguage, ContentLanguage.ar);
    });

    test('the language toggle applies to the source and the summary', () async {
      final cubit = recording()
        ..setText('Hello world')
        ..toggleLanguage();
      await cubit.submit();
      final stored = (await h.repo.getJob(cubit.state.submittedJobId!))!;
      expect(stored.sourceLanguage, ContentLanguage.en);
      expect(stored.summaryLanguage, ContentLanguage.en);
    });

    test('a YouTube job carries its URL', () async {
      final cubit = recording(supported: JobSourceType.values.toSet())
        ..changeSourceType(JobSourceType.youtube.index)
        ..setSourceUrl('  https://youtu.be/abc  ');
      await cubit.submit();
      final stored = (await h.repo.getJob(cubit.state.submittedJobId!))!;
      expect(stored.sourceType, JobSourceType.youtube);
      expect(stored.sourceUrl, 'https://youtu.be/abc');
      expect(stored.transcript, isNull);
    });

    test('an audio job carries its stored file, type and name', () async {
      final cubit = recording(supported: JobSourceType.values.toSet())..changeSourceType(JobSourceType.audio.index);
      cubit.emit(cubit.state.copyWith(pickedFile: audio));
      await cubit.submit();
      final stored = (await h.repo.getJob(cubit.state.submittedJobId!))!;
      expect(stored.sourceType, JobSourceType.audio);
      expect(stored.sourceFilePath, '/app/files/talk.m4a');
      expect(stored.sourceMimeType, 'audio/mp4');
      expect(stored.sourceTitle, 'talk.m4a');
    });

    test('submitting twice creates one job', () async {
      final cubit = recording()..setText('نص');
      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();
      expect(cubit.state.status, NewJobStatus.success);
      expect(scheduler.enqueued, hasLength(1));
    });

    test('nothing is saved when the form is not submittable', () async {
      final cubit = recording();
      await cubit.submit();
      expect(cubit.state.status, NewJobStatus.idle);
      expect(cubit.state.submittedJobId, isNull);
      expect(scheduler.enqueued, isEmpty);
    });

    test('end to end: a submitted job is picked up and finished by the queue', () async {
      final cubit = h.newJobCubit()..setText(sampleTranscript);
      addTearDown(cubit.close);
      await cubit.submit();
      final id = cubit.state.submittedJobId!;
      for (var i = 0; i < 300 && (await h.repo.getJob(id))!.status != JobRunStatus.completed; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect((await h.repo.getJob(id))!.status, JobRunStatus.completed);
    });

    test('a storage failure is reported, nothing is queued, and the sheet can retry', () async {
      final repo = JobsRepositoryImpl(
        FaultyJobsLocalDataSource(JobsLocalDataSourceImpl(h.db.jobsDao), {Fault.insertJob}),
        newId: () => 'x',
      );
      final failing = NewJobCubit(SubmitJob(repo, scheduler), supportedSources: const {JobSourceType.text});
      addTearDown(failing.close);
      failing.setText('نص');

      await failing.submit();
      expect(failing.state.status, NewJobStatus.failure);
      expect(failing.state.lastError, AppError.storage);
      expect(failing.state.submittedJobId, isNull);
      expect(failing.state.text, 'نص', reason: 'the user does not lose what they typed');
      expect(scheduler.enqueued, isEmpty);

      await failing.submit();
      expect(failing.state.status, NewJobStatus.failure, reason: 'a failed submit can be attempted again');
    });
  });
}
