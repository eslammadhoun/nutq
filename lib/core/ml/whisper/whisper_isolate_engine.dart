import 'dart:async';
import 'dart:isolate';

import 'package:nutq/core/ml/whisper/whisper_engine.dart';
import 'package:nutq/core/ml/whisper/whisper_engine_event.dart';
import 'package:nutq/core/ml/whisper/whisper_engine_impl.dart';

/// [WhisperEngine] that runs the real [WhisperEngineImpl] inside one
/// persistent worker [Isolate], spawned once and reused for every
/// `loadModel`/`transcribe`/`cancel`/`unloadModel` call — never a one-shot
/// `compute()`, which would re-pay whisper.cpp's multi-second model-load
/// cost on every call (plan Section 7).
///
/// This is the concrete engine `AsrPipeline` is wired with in production
/// (via DI); `AsrPipeline` itself only depends on the [WhisperEngine]
/// interface, so tests inject a fake/mock engine directly instead of
/// spawning a real isolate.
///
/// Only one `transcribe()` call is expected in flight at a time — matches
/// `AsrPipeline`'s sequential chunk-by-chunk driving and the plan's
/// sequential-only inference rule (Section 5) — a second concurrent call
/// before the first completes will have its events interleaved with the
/// first's on the single relay port and is not supported.
class WhisperIsolateEngine implements WhisperEngine {
  Isolate? _isolate;
  SendPort? _commandPort;
  ReceivePort? _fromWorker;
  StreamController<WhisperEngineEvent>? _activeTranscribeController;
  Completer<void>? _readyCompleter;

  Future<void> _ensureSpawned() async {
    if (_isolate != null) return;
    _readyCompleter = Completer<void>();
    _fromWorker = ReceivePort();
    _fromWorker!.listen(_onWorkerMessage);
    _isolate = await Isolate.spawn(_workerMain, _fromWorker!.sendPort);
    await _readyCompleter!.future;
  }

  void _onWorkerMessage(dynamic message) {
    if (message is SendPort) {
      _commandPort = message;
      _readyCompleter?.complete();
      return;
    }
    if (message is WhisperEngineEvent) {
      _activeTranscribeController?.add(message);
      if (message is WhisperEngineDone || message is WhisperEngineError) {
        unawaited(_activeTranscribeController?.close());
        _activeTranscribeController = null;
      }
    }
  }

  @override
  Future<void> loadModel(String modelPath) async {
    await _ensureSpawned();
    _commandPort!.send(_LoadModelCommand(modelPath));
  }

  @override
  Stream<WhisperEngineEvent> transcribe(String audioPath, {required String language}) {
    final controller = StreamController<WhisperEngineEvent>();
    _activeTranscribeController = controller;
    final port = _commandPort;
    if (port == null) {
      controller
        ..addError(StateError('WhisperIsolateEngine.transcribe() called before loadModel()'))
        ..close();
    } else {
      port.send(_TranscribeCommand(audioPath, language));
    }
    return controller.stream;
  }

  @override
  Future<void> cancel() async {
    _commandPort?.send(const _CancelCommand());
  }

  @override
  Future<void> unloadModel() async {
    _commandPort?.send(const _UnloadModelCommand());
  }

  /// Tears down the worker isolate. Not part of [WhisperEngine] — called by
  /// whoever owns this instance (e.g. `AsrPipeline` on app shutdown or when
  /// no job is active for the idle-timeout window).
  Future<void> dispose() async {
    _commandPort?.send(const _ShutdownCommand());
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _commandPort = null;
    _fromWorker?.close();
    _fromWorker = null;
  }

  static void _workerMain(SendPort toMain) {
    final commandPort = ReceivePort();
    toMain.send(commandPort.sendPort);
    final engine = WhisperEngineImpl();

    commandPort.listen((dynamic command) async {
      switch (command) {
        case _LoadModelCommand(:final path):
          await engine.loadModel(path);
        case _TranscribeCommand(:final audioPath, :final language):
          await for (final event in engine.transcribe(audioPath, language: language)) {
            toMain.send(event);
          }
        case _CancelCommand():
          await engine.cancel();
        case _UnloadModelCommand():
          await engine.unloadModel();
        case _ShutdownCommand():
          commandPort.close();
      }
    });
  }
}

class _LoadModelCommand {
  const _LoadModelCommand(this.path);
  final String path;
}

class _TranscribeCommand {
  const _TranscribeCommand(this.audioPath, this.language);
  final String audioPath;
  final String language;
}

class _CancelCommand {
  const _CancelCommand();
}

class _UnloadModelCommand {
  const _UnloadModelCommand();
}

class _ShutdownCommand {
  const _ShutdownCommand();
}
