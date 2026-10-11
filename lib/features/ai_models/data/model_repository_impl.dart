import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/core/utils/throttler.dart';
import 'package:nutq/features/ai_models/data/file_downloader.dart';
import 'package:nutq/features/ai_models/data/model_storage.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:path/path.dart' as p;

/// [ModelRepository] on the file system: `<root>/<pack id>/<version>/<file>`.
///
/// A file exists at its final path only once its checksum matched (see
/// [FileDownloader]), so a pack whose files are all there at the right size is
/// ready without hashing them again at every launch.
class ModelRepositoryImpl implements ModelRepository {
  ModelRepositoryImpl({
    required this._loadPacks,
    required this._storage,
    FileDownloader? downloader,
    this.freeSpaceMargin = 100 * 1024 * 1024,
    this._progressInterval = const Duration(milliseconds: 250),
  }) : _downloader = downloader ?? FileDownloader();

  @override
  late final List<ModelPack> packs;

  /// Room left free beyond the download itself, so the phone is not filled to
  /// the last byte.
  final int freeSpaceMargin;

  final Future<List<ModelPack>> Function() _loadPacks;
  final ModelStorage _storage;
  final FileDownloader _downloader;
  final Duration _progressInterval;

  late final String _root;
  final _statuses = <String, ModelPackStatus>{};
  final _changes = StreamController<Map<String, ModelPackStatus>>.broadcast();

  final _queue = <String>[];
  Completer<void>? _drained;
  CancellationToken? _cancellation;

  @override
  Map<String, ModelPackStatus> get statuses => Map.unmodifiable(_statuses);

  @override
  Stream<Map<String, ModelPackStatus>> get changes => _changes.stream;

  @override
  Future<void> init() async {
    packs = await _loadPacks();
    _root = await _storage.root();
    await _removeUnknownFolders();
    for (final pack in packs) {
      _statuses[pack.id] = await _scan(pack);
    }
    _emit();
  }

  @override
  ModelPack get summarizer => packs.firstWhere((pack) => pack.kind == ModelKind.summarizer);

  @override
  ModelPack transcriberFor(ContentLanguage language) =>
      packs.firstWhere((pack) => pack.kind == ModelKind.transcriber && pack.language == language);

  @override
  List<ModelPack> requiredFor(JobSourceType type, ContentLanguage language) => [
    summarizer,
    if (type == JobSourceType.audio || type == JobSourceType.video) transcriberFor(language),
  ];

  @override
  Future<void> download(Iterable<String> ids) {
    for (final id in ids) {
      final status = _statuses[id]!;
      if (status.isReady || _queue.contains(id)) continue;
      _queue.add(id);
      // Waiting packs show as downloading too, so a tap is seen at once.
      _set(_pack(id), ModelPackPhase.downloading, status.receivedBytes);
    }
    final running = _drained;
    if (running != null) return running.future;
    if (_queue.isEmpty) return Future.value();
    final drained = _drained = Completer<void>();
    unawaited(_drain(drained));
    return drained.future;
  }

  Future<void> _drain(Completer<void> drained) async {
    try {
      while (_queue.isNotEmpty) {
        final id = _queue.first;
        await _downloadPack(_pack(id));
        _queue.remove(id);
      }
    } finally {
      _drained = null;
      _cancellation = null;
      drained.complete();
    }
  }

  Future<void> _downloadPack(ModelPack pack) async {
    final cancellation = _cancellation = CancellationToken();
    final received = _statuses[pack.id]!.receivedBytes;
    final free = await _storage.freeBytes();
    if (free != null && free < pack.bytes - received + freeSpaceMargin) {
      _set(pack, ModelPackPhase.failed, received, AppError.modelDownloadNoSpace);
      return;
    }

    final progress = Throttler<int>(
      _progressInterval,
      (bytes) => _set(pack, ModelPackPhase.downloading, bytes),
    );
    _set(pack, ModelPackPhase.downloading, received);
    try {
      var done = 0;
      for (final file in pack.files) {
        final target = File(p.join(directoryOf(pack.id), file.name));
        if (!await _isComplete(target, file)) {
          await _downloader.download(
            file,
            target,
            onReceived: (bytes) => progress.add(done + bytes),
            cancellation: cancellation,
          );
        }
        done += file.bytes;
      }
      progress.cancel();
      _set(pack, ModelPackPhase.ready, pack.bytes);
    } on CancelledException {
      progress.cancel();
      _statuses[pack.id] = await _scan(pack);
      _emit();
    } on ModelDownloadException catch (e) {
      progress.cancel();
      debugPrint('Model download failed: ${pack.id}: $e');
      final scanned = await _scan(pack);
      _set(pack, ModelPackPhase.failed, scanned.receivedBytes, e.error);
    }
  }

  @override
  void cancel() {
    // The running pack settles in [_downloadPack]; the waiting ones here.
    final running = _drained == null ? null : _queue.firstOrNull;
    for (final id in _queue.where((id) => id != running)) {
      _set(_pack(id), ModelPackPhase.missing, _statuses[id]!.receivedBytes);
    }
    _queue.clear();
    _cancellation?.cancel();
  }

  @override
  Future<void> delete(String id) async {
    if (_queue.contains(id)) {
      cancel();
      await _drained?.future;
    }
    final folder = Directory(p.join(_root, id));
    if (await folder.exists()) await folder.delete(recursive: true);
    _set(_pack(id), ModelPackPhase.missing, 0);
  }

  @override
  String directoryOf(String id) => p.join(_root, id, _pack(id).version);

  @override
  String fileOf(String id) => p.join(directoryOf(id), _pack(id).files.single.name);

  ModelPack _pack(String id) => packs.firstWhere((pack) => pack.id == id);

  /// Ready when every file is in place; otherwise missing, with the bytes a
  /// resumed download will not fetch again.
  Future<ModelPackStatus> _scan(ModelPack pack) async {
    var received = 0;
    var complete = true;
    for (final file in pack.files) {
      final target = File(p.join(directoryOf(pack.id), file.name));
      if (await _isComplete(target, file)) {
        received += file.bytes;
        continue;
      }
      complete = false;
      final part = FileDownloader.partOf(target);
      if (await part.exists()) received += (await part.length()).clamp(0, file.bytes);
    }
    return ModelPackStatus(
      phase: complete ? ModelPackPhase.ready : ModelPackPhase.missing,
      receivedBytes: received,
      totalBytes: pack.bytes,
    );
  }

  Future<bool> _isComplete(File target, ModelFile file) async =>
      await target.exists() && await target.length() == file.bytes;

  /// Old versions and packs the app no longer uses: only the current
  /// `<id>/<version>` folders are kept.
  Future<void> _removeUnknownFolders() async {
    final root = Directory(_root);
    if (!await root.exists()) return;
    final wanted = {for (final pack in packs) pack.id: pack.version};
    await for (final entry in root.list()) {
      final version = wanted[p.basename(entry.path)];
      if (version == null) {
        await entry.delete(recursive: true);
        continue;
      }
      if (entry is! Directory) continue;
      await for (final child in entry.list()) {
        if (p.basename(child.path) != version) await child.delete(recursive: true);
      }
    }
  }

  void _set(ModelPack pack, ModelPackPhase phase, int received, [AppError? error]) {
    _statuses[pack.id] = ModelPackStatus(
      phase: phase,
      receivedBytes: received,
      totalBytes: pack.bytes,
      error: error,
    );
    _emit();
  }

  void _emit() => _changes.add(statuses);
}
