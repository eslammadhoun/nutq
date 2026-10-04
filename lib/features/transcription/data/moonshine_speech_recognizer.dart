import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';

/// A bundled Moonshine model. Moonshine publishes one model per language, so
/// choosing the language chooses the model; audio run through the wrong one
/// comes out as fragments of the other script.
class MoonshineModel {
  const MoonshineModel({required this.directory, required this.version});

  /// Folder under `ios/Runner/moonshine_models/`, resolved by the bridge
  /// inside the app bundle. See `third_party/moonshine/fetch-model.sh`.
  final String directory;

  /// The CDN release the weights came from.
  final String version;

  static const arabic = MoonshineModel(
    directory: 'tiny-streaming-ar',
    version: 'quantized_26_08_24',
  );
  static const english = MoonshineModel(
    directory: 'tiny-streaming-en',
    version: 'quantized_26_08_21',
  );

  static MoonshineModel of(ContentLanguage language) => switch (language) {
    ContentLanguage.ar => arabic,
    ContentLanguage.en => english,
  };

  String get name => 'moonshine-$directory';
}

/// Moonshine inference through the native bridge in
/// `ios/Runner/MoonshineBridge.swift`. iOS only.
///
/// The bridge feeds the file to Moonshine's streaming API in [chunkSeconds]
/// pieces, which is what gives a real progress fraction and lets [cancel] stop
/// between chunks. The model is released after every run, so it never sits in
/// memory next to the summarization model.
class MoonshineSpeechRecognizer implements SpeechRecognizer {
  MoonshineSpeechRecognizer({
    MethodChannel? channel,
    EventChannel? progressChannel,
    bool? isAvailable,
  }) : _channel = channel ?? const MethodChannel(channelName),
       _progress = progressChannel ?? const EventChannel(progressChannelName),
       isAvailable = isAvailable ?? Platform.isIOS;

  static const channelName = 'nutq/moonshine';

  /// Progress events, separate from [channelName] because they are a stream,
  /// not a request/response.
  static const progressChannelName = '$channelName/progress';

  /// `MOONSHINE_MODEL_ARCH_TINY_STREAMING` in `moonshine-c-api.h`.
  static const modelArchTinyStreaming = 2;

  /// Seconds of audio per streaming pass. Measured in whisper_playground on a
  /// 194 s clip: 5 s chunks cost 18% more than 20 s for the same transcript.
  /// The playground chose 5 s to show live text; Nutq shows none, so it takes
  /// the faster setting.
  static const chunkSeconds = 20.0;

  /// The bridge's error code for a run stopped by [cancel].
  static const _cancelledCode = 'moonshine_cancelled';

  final MethodChannel _channel;
  final EventChannel _progress;

  @override
  final bool isAvailable;

  @override
  Future<RecognizedSpeech> transcribe({
    required String audioPath,
    required ContentLanguage language,
    void Function(double progress)? onProgress,
  }) async {
    if (!isAvailable) {
      throw const SpeechRecognitionException('Moonshine is only available on iOS');
    }
    final model = MoonshineModel.of(language);
    onProgress?.call(0);

    // Subscribed before the call, because the bridge reports progress while
    // the call is in flight. Best-effort: a failure here must not mask the
    // transcription result.
    final subscription = _progress.receiveBroadcastStream().listen(
      (event) {
        if (event is! Map) return;
        final progress = (event['progress'] as num?)?.toDouble();
        if (progress != null) onProgress?.call(progress.clamp(0, 1));
      },
      onError: (Object _) {},
    );

    final List<Object?> lines;
    try {
      lines =
          await _channel.invokeListMethod<Object?>('transcribe', {
            'audioPath': audioPath,
            'modelPath': model.directory,
            'modelArch': modelArchTinyStreaming,
            'keepLoaded': false,
            'chunkSeconds': chunkSeconds,
            'startFrame': 0,
          }) ??
          const [];
    } on PlatformException catch (e) {
      if (e.code == _cancelledCode) throw const CancelledException();
      throw SpeechRecognitionException(e.message ?? e.code);
    } on MissingPluginException {
      throw const SpeechRecognitionException('Moonshine bridge is not registered');
    } finally {
      await subscription.cancel();
      // The bridge frees the model after a successful run but keeps it after a
      // failure or cancel; release it so it never sits next to Gemma.
      await _quietly('release');
    }

    onProgress?.call(1);
    return RecognizedSpeech(
      text: textOf(lines),
      modelName: model.name,
      modelVersion: model.version,
    );
  }

  /// Joins the bridge's line maps (`text`, `start`, `duration`) into text, one
  /// line per row.
  static String textOf(List<Object?> lines) => [
    for (final line in lines)
      if (line is Map && line['text'] is String && (line['text'] as String).trim().isNotEmpty)
        (line['text'] as String).trim(),
  ].join('\n');

  @override
  Future<void> cancel() => _quietly('cancel');

  @override
  Future<void> pause() => _quietly('pause');

  @override
  Future<void> resume() => _quietly('resume');

  /// For requests that may arrive after the run ended: there is nothing useful
  /// to report if the bridge cannot act on them.
  Future<void> _quietly(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // No bridge on this platform.
    } on PlatformException {
      // The run finished in the meantime.
    }
  }
}
