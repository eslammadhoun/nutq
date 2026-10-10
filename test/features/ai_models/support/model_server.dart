import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';

/// A local HTTP server for model files, with the behaviors downloads must
/// survive: Range requests, a redirect to another path (as Hugging Face does),
/// a server that ignores Range, and a connection dropped partway.
class ModelServer {
  ModelServer._(this._server) {
    _server.listen(_handle);
  }

  static Future<ModelServer> start() async =>
      ModelServer._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  final HttpServer _server;
  final _files = <String, Uint8List>{};

  /// The Range header of every request for a file, null when there was none.
  final ranges = <String?>[];

  /// Ignore Range and always send the whole file.
  bool ignoreRange = false;

  /// Close the connection after sending this many bytes of the next response.
  int? dropAfter;

  /// Answer every request for a file with this status instead.
  int? failWith;

  Uri get base => Uri.parse('http://${_server.address.host}:${_server.port}/');

  /// Serves [bytes] at `/<name>` and, through a redirect, at `/redirect/<name>`.
  ModelFile serve(String name, Uint8List bytes, {bool viaRedirect = false, String? sha}) {
    _files[name] = bytes;
    return ModelFile(
      name: name,
      url: base.resolve(viaRedirect ? 'redirect/$name' : name),
      bytes: bytes.length,
      sha256: sha ?? sha256.convert(bytes).toString(),
    );
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    final path = request.uri.path.substring(1);
    if (path.startsWith('redirect/')) {
      response
        ..statusCode = HttpStatus.found
        ..headers.set(HttpHeaders.locationHeader, '/${path.substring('redirect/'.length)}');
      await response.close();
      return;
    }
    final bytes = _files[path];
    if (bytes == null) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    final range = request.headers.value(HttpHeaders.rangeHeader);
    ranges.add(range);
    if (failWith != null) {
      response.statusCode = failWith!;
      await response.close();
      return;
    }

    var start = 0;
    if (range != null && !ignoreRange) {
      start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
      if (start >= bytes.length) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        await response.close();
        return;
      }
      response
        ..statusCode = HttpStatus.partialContent
        ..headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-${bytes.length - 1}/${bytes.length}',
        );
    }
    final body = bytes.sublist(start);
    response.contentLength = body.length;

    final drop = dropAfter;
    if (drop == null) {
      response.add(body);
      await response.close();
      return;
    }
    dropAfter = null;
    final socket = await response.detachSocket();
    socket.add(body.sublist(0, drop));
    await socket.flush();
    socket.destroy();
  }
}

/// Bytes that differ from position to position, so a misplaced resume shows.
Uint8List patternBytes(int length, [int seed = 0]) =>
    Uint8List.fromList([for (var i = 0; i < length; i++) (i * 31 + seed) % 251]);
