import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/data/file_downloader.dart';
import 'package:nutq/features/ai_models/data/model_manifest.dart';
import 'package:nutq/features/ai_models/data/model_repository_impl.dart';
import 'package:nutq/features/ai_models/data/model_storage.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:path/path.dart' as p;

import 'support/model_server.dart';

class _TempStorage implements ModelStorage {
  _TempStorage(this.path);

  final String path;
  int? free;
  List<String> engineFolders = [];

  @override
  Future<String> root() async => path;

  @override
  Future<int?> freeBytes() async => free;

  @override
  Future<List<String>> engineCacheFolders() async => engineFolders;
}

void main() {
  late ModelServer server;
  late Directory dir;
  late _TempStorage storage;
  late Uint8List gemmaBytes;
  late List<ModelPack> packs;

  setUp(() async {
    server = await ModelServer.start();
    dir = await Directory.systemTemp.createTemp('nutq_models_');
    storage = _TempStorage(dir.path);
    gemmaBytes = patternBytes(256 * 1024);
    packs = [
      ModelPack(
        id: 'gemma',
        kind: ModelKind.summarizer,
        language: ContentLanguage.ar,
        version: 'v3',
        files: [server.serve('gemma.litertlm', gemmaBytes)],
      ),
      ModelPack(
        id: 'moonshine-ar',
        kind: ModelKind.transcriber,
        language: ContentLanguage.ar,
        version: 'q1',
        files: [
          server.serve('encoder.ort', patternBytes(64 * 1024, 1)),
          server.serve('tokenizer.bin', patternBytes(8 * 1024, 2)),
        ],
      ),
      ModelPack(
        id: 'moonshine-en',
        kind: ModelKind.transcriber,
        language: ContentLanguage.en,
        version: 'q1',
        files: [server.serve('encoder-en.ort', patternBytes(32 * 1024, 3))],
      ),
    ];
  });
  tearDown(() async {
    await server.close();
    await dir.delete(recursive: true);
  });

  Future<ModelRepositoryImpl> repository({List<ModelPack>? withPacks}) async {
    final repository = ModelRepositoryImpl(
      loadPacks: () async => withPacks ?? packs,
      storage: storage,
      freeSpaceMargin: 0,
      progressInterval: Duration.zero,
    );
    await repository.init();
    return repository;
  }

  test('the bundled manifest lists the summarizer and both transcribers', () async {
    final manifest = ModelManifest.parse(
      await File('assets/models/manifest.json').readAsString(),
    );
    expect(manifest.map((pack) => pack.id), ['gemma-summarizer', 'moonshine-ar', 'moonshine-en']);
    expect(manifest.first.files.single.url.host, 'huggingface.co');
    for (final file in manifest.expand((pack) => pack.files)) {
      expect(file.sha256, matches(RegExp(r'^[0-9a-f]{64}$')), reason: file.name);
    }
  });

  test('a fresh install has every pack missing', () async {
    final models = await repository();

    for (final pack in packs) {
      expect(
        models.statuses[pack.id],
        ModelPackStatus(phase: ModelPackPhase.missing, totalBytes: pack.bytes),
      );
    }
  });

  test('downloads a pack into <root>/<id>/<version>/', () async {
    final models = await repository();
    final phases = <ModelPackPhase>[];
    final subscription = models.changes.listen((s) => phases.add(s['gemma']!.phase));

    await models.download(['gemma']);
    await subscription.cancel();

    expect(models.statuses['gemma']!.isReady, isTrue);
    expect(phases, containsAllInOrder([ModelPackPhase.downloading, ModelPackPhase.ready]));
    expect(models.fileOf('gemma'), p.join(dir.path, 'gemma', 'v3', 'gemma.litertlm'));
    expect(await File(models.fileOf('gemma')).readAsBytes(), gemmaBytes);
    expect(Directory(models.directoryOf('moonshine-ar')).existsSync(), isFalse);
  });

  test('a downloaded pack is ready on the next launch', () async {
    await (await repository()).download(['moonshine-ar']);

    final relaunched = await repository();

    expect(relaunched.statuses['moonshine-ar']!.isReady, isTrue);
    expect(relaunched.statuses['gemma']!.isReady, isFalse);
  });

  test('a partial download is counted, and resumed rather than fetched again', () async {
    final target = File(p.join(dir.path, 'gemma', 'v3', 'gemma.litertlm'));
    await target.parent.create(recursive: true);
    await FileDownloader.partOf(target).writeAsBytes(gemmaBytes.sublist(0, 1000));

    final models = await repository();
    expect(models.statuses['gemma']!.receivedBytes, 1000);

    await models.download(['gemma']);
    expect(models.statuses['gemma']!.isReady, isTrue);
    expect(server.ranges, ['bytes=1000-']);
  });

  test('without room for it, a download fails before fetching anything', () async {
    final models = await repository();
    storage.free = 1000;

    await models.download(['gemma']);

    expect(models.statuses['gemma']!.phase, ModelPackPhase.failed);
    expect(models.statuses['gemma']!.error, AppError.modelDownloadNoSpace);
    expect(server.ranges, isEmpty);
  });

  test('one failed pack does not stop the others', () async {
    final corrupt = ModelPack(
      id: 'gemma',
      kind: ModelKind.summarizer,
      language: ContentLanguage.ar,
      version: 'v3',
      files: [server.serve('gemma.litertlm', gemmaBytes, sha: 'wrong')],
    );
    final models = await repository(withPacks: [corrupt, packs[1], packs[2]]);

    await models.download(['gemma', 'moonshine-ar']);

    expect(models.statuses['gemma']!.error, AppError.modelDownloadCorrupt);
    expect(models.statuses['moonshine-ar']!.isReady, isTrue);
  });

  test('cancel stops the download and keeps what arrived for later', () async {
    final models = await repository();
    final subscription = models.changes.listen((statuses) {
      if (statuses['gemma']!.receivedBytes > 0) models.cancel();
    });

    await models.download(['gemma', 'moonshine-ar']);
    await subscription.cancel();

    expect(models.statuses['gemma']!.phase, ModelPackPhase.missing);
    expect(models.statuses['moonshine-ar']!.phase, ModelPackPhase.missing);

    await models.download(['gemma']);
    expect(models.statuses['gemma']!.isReady, isTrue);
  });

  test('a pack waiting in the queue shows as downloading at once', () async {
    final models = await repository();

    final done = models.download(['gemma', 'moonshine-en']);

    expect(models.statuses['moonshine-en']!.phase, ModelPackPhase.downloading);
    models.cancel();
    expect(models.statuses['moonshine-en']!.phase, ModelPackPhase.missing);
    await done;
    expect(models.statuses['gemma']!.phase, ModelPackPhase.missing);
  });

  test('downloads asked for while one runs join the same queue', () async {
    final models = await repository();

    await Future.wait([
      models.download(['gemma']),
      models.download(['moonshine-en']),
    ]);

    expect(models.statuses['gemma']!.isReady, isTrue);
    expect(models.statuses['moonshine-en']!.isReady, isTrue);
  });

  test('delete removes the files and the pack is missing again', () async {
    final models = await repository();
    await models.download(['gemma']);

    await models.delete('gemma');

    expect(
      models.statuses['gemma'],
      ModelPackStatus(phase: ModelPackPhase.missing, totalBytes: gemmaBytes.length),
    );
    expect(Directory(p.join(dir.path, 'gemma')).existsSync(), isFalse);
  });

  test('only the newest engine cache of a ready summarizer is kept', () async {
    await (await repository()).download(['gemma']);
    final engine = Directory(p.join(dir.path, '..', '${p.basename(dir.path)}_engine'))
      ..createSync();
    addTearDown(() => engine.deleteSync(recursive: true));
    storage.engineFolders = [engine.path];
    File cache(String name, DateTime modified) => File(p.join(engine.path, name))
      ..writeAsBytesSync([1])
      ..setLastModifiedSync(modified);
    final old = cache('gemma.litertlm_100_9.xnnpack_cache', DateTime(2026));
    final current = cache('gemma.litertlm_200_9.xnnpack_cache', DateTime(2026, 2));
    final unknown = cache('other.litertlm_1_1.xnnpack_cache', DateTime(2026, 3));
    final unrelated = File(p.join(engine.path, 'jobs.sqlite'))..writeAsBytesSync([1]);

    final models = await repository();

    expect(old.existsSync(), isFalse);
    expect(current.existsSync(), isTrue);
    expect(unknown.existsSync(), isFalse);
    expect(unrelated.existsSync(), isTrue);

    await models.delete('gemma');
    expect(current.existsSync(), isFalse);
  });

  test('old versions and unknown packs are cleaned up at launch', () async {
    await Directory(p.join(dir.path, 'gemma', 'v2')).create(recursive: true);
    await Directory(p.join(dir.path, 'gemma', 'v3')).create(recursive: true);
    await Directory(p.join(dir.path, 'retired-model', 'v1')).create(recursive: true);

    await repository();

    expect(Directory(p.join(dir.path, 'gemma', 'v2')).existsSync(), isFalse);
    expect(Directory(p.join(dir.path, 'gemma', 'v3')).existsSync(), isTrue);
    expect(Directory(p.join(dir.path, 'retired-model')).existsSync(), isFalse);
  });

  test('a job needs the summarizer, plus the transcriber for audio and video', () async {
    final models = await repository();
    List<String> ids(JobSourceType type, ContentLanguage language) =>
        models.requiredFor(type, language).map((pack) => pack.id).toList();

    expect(ids(JobSourceType.text, ContentLanguage.en), ['gemma']);
    expect(ids(JobSourceType.youtube, ContentLanguage.ar), ['gemma']);
    expect(ids(JobSourceType.audio, ContentLanguage.ar), ['gemma', 'moonshine-ar']);
    expect(ids(JobSourceType.video, ContentLanguage.en), ['gemma', 'moonshine-en']);
  });
}
