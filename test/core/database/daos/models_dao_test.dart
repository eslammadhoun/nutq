import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/database/app_database.dart';

void main() {
  group('ModelsDao', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    InstalledModelsCompanion entry(String id) => InstalledModelsCompanion.insert(
      modelId: id,
      kind: 'whisper',
      tier: id,
      filePath: '/models/ggml-$id.bin',
      downloadedAt: DateTime.utc(2026, 9, 1),
      sizeBytes: 1000,
      checksum: 'size:1000',
    );

    test('upsert then getInstalled returns the row', () async {
      await db.modelsDao.upsert(entry('small'));
      final row = await db.modelsDao.getInstalled('small');
      expect(row, isNotNull);
      expect(row!.tier, 'small');
      expect(row.filePath, '/models/ggml-small.bin');
    });

    test('getInstalled returns null for an unknown model', () async {
      final row = await db.modelsDao.getInstalled('medium');
      expect(row, isNull);
    });

    test('upsert on an existing modelId replaces the row (conflict update)', () async {
      await db.modelsDao.upsert(entry('base'));
      await db.modelsDao.upsert(
        InstalledModelsCompanion.insert(
          modelId: 'base',
          kind: 'whisper',
          tier: 'base',
          filePath: '/models/ggml-base-v2.bin',
          downloadedAt: DateTime.utc(2026, 9, 2),
          sizeBytes: 2000,
          checksum: 'size:2000',
        ),
      );

      final all = await db.modelsDao.listInstalled();
      expect(all, hasLength(1));
      expect(all.single.filePath, '/models/ggml-base-v2.bin');
    });

    test('listInstalled returns every installed model', () async {
      await db.modelsDao.upsert(entry('base'));
      await db.modelsDao.upsert(entry('small'));
      final all = await db.modelsDao.listInstalled();
      expect(all.map((r) => r.modelId).toSet(), {'base', 'small'});
    });

    test('deleteModel removes the row', () async {
      await db.modelsDao.upsert(entry('small'));
      await db.modelsDao.deleteModel('small');
      final row = await db.modelsDao.getInstalled('small');
      expect(row, isNull);
    });
  });
}
