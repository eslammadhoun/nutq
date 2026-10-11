import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';

/// A download that stopped for [error]. Cancelling throws
/// [CancelledException] instead.
class ModelDownloadException implements Exception {
  const ModelDownloadException(this.error, [this.detail]);

  final AppError error;
  final Object? detail;

  @override
  String toString() => 'ModelDownloadException($error, $detail)';
}

/// Downloads one [ModelFile] to disk.
///
/// Bytes go to `<target>.part`, so an interrupted download resumes from where
/// it stopped (an HTTP Range request). The file is renamed to [target] only
/// after its SHA-256 matches the manifest: a file at the final path is always
/// complete and genuine.
class FileDownloader {
  FileDownloader({HttpClient Function()? newClient}) : _newClient = newClient ?? HttpClient.new;

  final HttpClient Function() _newClient;

  /// A connection that delivers nothing for this long is treated as lost.
  static const stallTimeout = Duration(seconds: 45);

  /// `ENOSPC` on both iOS and Android.
  static const _noSpaceErrno = 28;

  /// Redirects are followed by hand: Hugging Face answers with a redirect to
  /// its CDN, and the Range header has to reach the CDN too.
  static const _maxRedirects = 5;

  static File partOf(File target) => File('${target.path}.part');

  /// Downloads [file] to [target], reporting the bytes on disk so far
  /// (including what an earlier attempt left) through [onReceived].
  Future<void> download(
    ModelFile file,
    File target, {
    void Function(int receivedBytes)? onReceived,
    CancellationToken? cancellation,
  }) async {
    final part = partOf(target);
    try {
      await part.parent.create(recursive: true);
      var have = await part.exists() ? await part.length() : 0;
      if (have > file.bytes) {
        await part.delete();
        have = 0;
      }
      onReceived?.call(have);
      if (have < file.bytes) {
        await _fetch(file, part, have, onReceived, cancellation);
      }
      cancellation?.throwIfCancelled();
      await _verify(file, part);
      if (await target.exists()) await target.delete();
      await part.rename(target.path);
    } on CancelledException {
      rethrow;
    } on ModelDownloadException {
      rethrow;
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == _noSpaceErrno) {
        throw ModelDownloadException(AppError.modelDownloadNoSpace, e);
      }
      throw ModelDownloadException(AppError.storage, e);
    } on Exception catch (e) {
      // Socket, TLS, HTTP and timeout failures: all a lost connection to the user.
      if (cancellation?.isCancelled ?? false) throw const CancelledException();
      throw ModelDownloadException(AppError.modelDownloadNetwork, e);
    }
  }

  Future<void> _fetch(
    ModelFile file,
    File part,
    int have,
    void Function(int)? onReceived,
    CancellationToken? cancellation,
  ) async {
    cancellation?.throwIfCancelled();
    final client = _newClient()
      ..connectionTimeout = const Duration(seconds: 30)
      // The bytes are stored and checked exactly as sent; see [_get].
      ..autoUncompress = false;
    // Closing the client aborts a read that is waiting on the network.
    final unregister = cancellation?.onCancel(() => client.close(force: true));
    try {
      final response = await _get(client, file.url, have);
      final resumed = response.statusCode == HttpStatus.partialContent;
      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
        // The partial file no longer fits the file on the server: start over.
        await response.drain<void>();
        await part.delete();
        throw ModelDownloadException(AppError.modelDownloadCorrupt, 'HTTP 416 for ${file.url}');
      }
      if (!resumed && response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw ModelDownloadException(
          AppError.modelDownloadNetwork,
          'HTTP ${response.statusCode} for ${file.url}',
        );
      }
      // A server that ignores Range sends everything again from the start.
      var received = resumed ? have : 0;
      final sink = part.openWrite(mode: resumed ? FileMode.writeOnlyAppend : FileMode.writeOnly);
      try {
        await for (final chunk in response.timeout(stallTimeout)) {
          cancellation?.throwIfCancelled();
          sink.add(chunk);
          received += chunk.length;
          onReceived?.call(received);
        }
      } finally {
        await sink.close();
      }
      cancellation?.throwIfCancelled();
    } finally {
      unregister?.call();
      client.close(force: true);
    }
  }

  Future<HttpClientResponse> _get(HttpClient client, Uri url, int from) async {
    var location = url;
    for (var hop = 0; hop <= _maxRedirects; hop++) {
      final request = await client.getUrl(location)
        ..followRedirects = false;
      // Without this a server may gzip the file (download.moonshine.ai does
      // for JSON), and the compressed bytes would fail the checksum.
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      if (from > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$from-');
      final response = await request.close();
      if (!response.isRedirect) return response;
      final next = response.headers.value(HttpHeaders.locationHeader);
      await response.drain<void>();
      if (next == null) break;
      location = location.resolve(next);
    }
    throw ModelDownloadException(AppError.modelDownloadNetwork, 'too many redirects for $url');
  }

  /// Hashing hundreds of MB takes seconds, so it runs off the UI isolate.
  Future<void> _verify(ModelFile file, File part) async {
    final length = await part.length();
    final path = part.path;
    final digest = length == file.bytes
        ? await Isolate.run(() async => (await sha256.bind(File(path).openRead()).first).toString())
        : null;
    if (digest != file.sha256) {
      await part.delete();
      throw ModelDownloadException(
        AppError.modelDownloadCorrupt,
        '${file.name}: $length bytes, sha256 $digest',
      );
    }
  }
}
