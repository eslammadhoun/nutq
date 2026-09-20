import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Optional development cache for model outputs, keyed by
/// `SHA-256(modelVersion + promptVersion + stage + input + generationConfig)`.
/// Changing the prompt version changes every key, which invalidates the cache.
abstract class SummarizationCache {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  static String keyFor({
    required String modelVersion,
    required String promptVersion,
    required String stage,
    required String input,
    required String configSignature,
  }) => sha256
      .convert(
        utf8.encode(
          '$modelVersion\u0000$promptVersion\u0000$stage\u0000$input\u0000$configSignature',
        ),
      )
      .toString();
}

class InMemorySummarizationCache implements SummarizationCache {
  final Map<String, String> _store = {};

  int get length => _store.length;

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;
}

/// One file per entry under [directory]. Meant for development runs; the
/// caller decides where the directory lives.
class FileSummarizationCache implements SummarizationCache {
  FileSummarizationCache(this.directory);

  final Directory directory;

  File _file(String key) => File('${directory.path}/$key.txt');

  @override
  Future<String?> read(String key) async {
    final file = _file(key);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String key, String value) async {
    await directory.create(recursive: true);
    await _file(key).writeAsString(value);
  }
}
