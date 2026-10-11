import 'dart:async';

import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';

ModelPack fakePack(String id, ModelKind kind, ContentLanguage language, int bytes) => ModelPack(
  id: id,
  kind: kind,
  language: language,
  version: '1',
  files: [ModelFile(name: '$id.bin', url: Uri.parse('https://x/$id'), bytes: bytes, sha256: '')],
);

/// In memory: [download] moves a pack to downloading, and [finish] / [fail]
/// end it, so tests see every step.
class FakeModelRepository implements ModelRepository {
  FakeModelRepository({Set<String> ready = const {}})
    : packs = [
        fakePack('gemma', ModelKind.summarizer, ContentLanguage.ar, 600 * 1024 * 1024),
        fakePack('moonshine-ar', ModelKind.transcriber, ContentLanguage.ar, 31 * 1024 * 1024),
        fakePack('moonshine-en', ModelKind.transcriber, ContentLanguage.en, 43 * 1024 * 1024),
      ] {
    for (final pack in packs) {
      _statuses[pack.id] = ModelPackStatus(
        phase: ready.contains(pack.id) ? ModelPackPhase.ready : ModelPackPhase.missing,
        receivedBytes: ready.contains(pack.id) ? pack.bytes : 0,
        totalBytes: pack.bytes,
      );
    }
  }

  @override
  final List<ModelPack> packs;

  final _statuses = <String, ModelPackStatus>{};
  final _changes = StreamController<Map<String, ModelPackStatus>>.broadcast();
  final downloads = <String>[];
  final deleted = <String>[];

  @override
  Future<void> init() async {}

  @override
  Map<String, ModelPackStatus> get statuses => Map.unmodifiable(_statuses);

  @override
  Stream<Map<String, ModelPackStatus>> get changes => _changes.stream;

  @override
  ModelPack get summarizer => packs.first;

  @override
  ModelPack transcriberFor(ContentLanguage language) =>
      packs.firstWhere((p) => p.kind == ModelKind.transcriber && p.language == language);

  @override
  List<ModelPack> requiredFor(JobSourceType type, ContentLanguage language) => [
    summarizer,
    if (type == JobSourceType.audio || type == JobSourceType.video) transcriberFor(language),
  ];

  @override
  Future<void> download(Iterable<String> ids) async {
    for (final id in ids) {
      if (_statuses[id]!.isReady) continue;
      downloads.add(id);
      _set(id, ModelPackPhase.downloading, _statuses[id]!.totalBytes ~/ 2);
    }
  }

  void finish(String id) => _set(id, ModelPackPhase.ready, _statuses[id]!.totalBytes);

  void fail(String id, AppError error) =>
      _set(id, ModelPackPhase.failed, _statuses[id]!.receivedBytes, error);

  @override
  void cancel() {
    for (final entry in _statuses.entries.toList()) {
      if (entry.value.phase == ModelPackPhase.downloading) {
        _set(entry.key, ModelPackPhase.missing, entry.value.receivedBytes);
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);
    _set(id, ModelPackPhase.missing, 0);
  }

  @override
  String directoryOf(String id) => '/models/$id';

  @override
  String fileOf(String id) => '/models/$id/$id.bin';

  void _set(String id, ModelPackPhase phase, int received, [AppError? error]) {
    _statuses[id] = ModelPackStatus(
      phase: phase,
      receivedBytes: received,
      totalBytes: _statuses[id]!.totalBytes,
      error: error,
    );
    _changes.add(statuses);
  }
}
