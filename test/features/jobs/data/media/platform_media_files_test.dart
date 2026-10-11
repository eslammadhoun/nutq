import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/data/media/platform_media_files.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;
  late PlatformMediaFiles media;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('job_media');
    media = PlatformMediaFiles(newId: () => 'id', storage: () async => dir);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  File file(String name, {required DateTime modified}) => File(p.join(dir.path, name))
    ..writeAsBytesSync(List.filled(10, 0))
    ..setLastModifiedSync(modified);

  final old = DateTime(2026);
  final cutoff = DateTime(2026, 6);

  test('deletes files no job keeps, matching kept files by name', () async {
    final kept = file('kept.mp4', modified: old);
    final unused = file('unused.mp4', modified: old);

    // The stored path is from before an iOS update moved the app's container.
    await media.deleteAllExcept(
      {'/old/container/job_media/kept.mp4'},
      modifiedBefore: cutoff,
    );

    expect(kept.existsSync(), isTrue);
    expect(unused.existsSync(), isFalse);
    expect(await media.storageBytes(), 10);
  });

  test('spares a file imported after the cutoff (a job being submitted)', () async {
    final fresh = file('fresh.mp4', modified: DateTime(2026, 7));
    await media.deleteAllExcept({}, modifiedBefore: cutoff);
    expect(fresh.existsSync(), isTrue);
  });

  test('a missing storage folder is not an error', () async {
    dir.deleteSync(recursive: true);
    await media.deleteAllExcept({}, modifiedBefore: cutoff);
    dir.createSync();
  });
}
