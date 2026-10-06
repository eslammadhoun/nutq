import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/profile/data/local_job_storage.dart';
import 'package:nutq/features/profile/domain/job_storage.dart';
import 'package:nutq/features/profile/presentation/cubit/profile_cubit.dart';

import '../../support/async_helpers.dart';
import '../jobs/support/job_harness.dart';

class _FailingStorage implements JobStorage {
  @override
  Future<StorageUsage> usage() async => throw StateError('disk');

  @override
  Future<void> deleteAllJobs() async => throw StateError('disk');
}

void main() {
  late JobHarness h;
  late LocalJobStorage storage;

  setUp(() {
    h = JobHarness();
    h.media.bytes = 3 * 1024 * 1024;
    storage = LocalJobStorage(jobs: h.repo, media: h.media, scheduler: h.runner);
  });
  tearDown(() => h.dispose());

  test('reports how many jobs there are and how much media they take', () async {
    await h.createJob(sampleTranscript);
    await h.createJob(sampleTranscript);
    final usage = await storage.usage();
    expect(usage.jobs, 2);
    expect(formatBytes(usage.mediaBytes), '3 MB');
  });

  test('delete all removes every job, stopping one that is running', () async {
    await h.createJob(sampleTranscript);
    final running = await h.submit(sampleTranscript);
    await eventually(() async => (await h.repo.getJob(running))!.status.isActive);
    await storage.deleteAllJobs();
    expect((await storage.usage()).jobs, 0);
  });

  test('the cubit measures, deletes and reports storage errors', () async {
    await h.createJob(sampleTranscript);
    final cubit = ProfileCubit(storage);
    addTearDown(cubit.close);
    await cubit.refresh();
    expect(cubit.state.usage!.jobs, 1);
    await cubit.deleteAllJobs();
    expect(cubit.state.usage!.jobs, 0);
    expect(cubit.state.deleting, isFalse);

    final failing = ProfileCubit(_FailingStorage());
    addTearDown(failing.close);
    await failing.refresh();
    expect(failing.state.lastError, AppError.storage);
  });

  test('formatBytes', () {
    expect(formatBytes(500), '1 KB');
    expect(formatBytes(48 * 1024 * 1024), '48 MB');
    expect(formatBytes((1.25 * 1024 * 1024 * 1024).round()), '1.3 GB');
  });
}
