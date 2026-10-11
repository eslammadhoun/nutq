import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/cancellation.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/data/file_downloader.dart';

import 'support/model_server.dart';

void main() {
  late ModelServer server;
  late Directory dir;
  late File target;
  final downloader = FileDownloader();

  setUp(() async {
    server = await ModelServer.start();
    dir = await Directory.systemTemp.createTemp('nutq_download_');
    target = File('${dir.path}/model.bin');
  });
  tearDown(() async {
    await server.close();
    await dir.delete(recursive: true);
  });

  Matcher failsWith(AppError error) =>
      throwsA(isA<ModelDownloadException>().having((e) => e.error, 'error', error));

  test('downloads a file, verified, to its final path', () async {
    final bytes = patternBytes(300 * 1024);
    final file = server.serve('model.bin', bytes);
    final received = <int>[];

    await downloader.download(file, target, onReceived: received.add);

    expect(await target.readAsBytes(), bytes);
    expect(FileDownloader.partOf(target).existsSync(), isFalse);
    expect(received.last, bytes.length);
    expect(server.ranges, [null]);
  });

  test('follows a redirect and keeps the Range header', () async {
    final bytes = patternBytes(200 * 1024);
    final file = server.serve('model.bin', bytes, viaRedirect: true);
    await FileDownloader.partOf(target).writeAsBytes(bytes.sublist(0, 1000));

    await downloader.download(file, target);

    expect(await target.readAsBytes(), bytes);
    expect(server.ranges, ['bytes=1000-']);
  });

  test('stores the file as served, not gzipped, when the server would compress', () async {
    final bytes = utf8.encode(
      '{"encoder_dim": 288, "decoder_dim": 288, "padding": "${'x' * 400}"}',
    );
    final file = server.serve('streaming_config.json', bytes);
    server.gzipWhenAccepted = true;

    await downloader.download(file, target);

    expect(await target.readAsBytes(), bytes);
  });

  test('resumes after a dropped connection instead of starting over', () async {
    final bytes = patternBytes(400 * 1024);
    final file = server.serve('model.bin', bytes);
    server.dropAfter = 150 * 1024;

    await expectLater(downloader.download(file, target), failsWith(AppError.modelDownloadNetwork));
    final kept = FileDownloader.partOf(target).lengthSync();
    expect(kept, greaterThan(0));

    await downloader.download(file, target);

    expect(await target.readAsBytes(), bytes);
    expect(server.ranges.last, 'bytes=$kept-');
  });

  test('starts over when the server ignores Range', () async {
    final bytes = patternBytes(100 * 1024);
    final file = server.serve('model.bin', bytes);
    server.ignoreRange = true;
    await FileDownloader.partOf(target).writeAsBytes(bytes.sublist(0, 5000));

    await downloader.download(file, target);

    expect(await target.readAsBytes(), bytes);
  });

  test('a checksum mismatch throws the download away', () async {
    final file = server.serve('model.bin', patternBytes(50 * 1024), sha: 'not-the-hash');

    await expectLater(downloader.download(file, target), failsWith(AppError.modelDownloadCorrupt));

    expect(target.existsSync(), isFalse);
    expect(FileDownloader.partOf(target).existsSync(), isFalse);
  });

  test('a partial file the server cannot resume is discarded', () async {
    final bytes = patternBytes(10 * 1024);
    final file = server.serve('model.bin', bytes);
    server.failWith = HttpStatus.requestedRangeNotSatisfiable;
    await FileDownloader.partOf(target).writeAsBytes(bytes.sublist(0, 100));

    await expectLater(downloader.download(file, target), failsWith(AppError.modelDownloadCorrupt));

    expect(FileDownloader.partOf(target).existsSync(), isFalse);
  });

  test('a server error is a network failure', () async {
    final file = server.serve('model.bin', patternBytes(1024));
    server.failWith = HttpStatus.serviceUnavailable;

    await expectLater(downloader.download(file, target), failsWith(AppError.modelDownloadNetwork));
  });

  test('cancelling stops the download and keeps what arrived', () async {
    final bytes = patternBytes(4 * 1024 * 1024);
    final file = server.serve('model.bin', bytes);
    final cancellation = CancellationToken();

    await expectLater(
      downloader.download(
        file,
        target,
        cancellation: cancellation,
        onReceived: (received) {
          if (received > 0) cancellation.cancel();
        },
      ),
      throwsA(isA<CancelledException>()),
    );

    expect(target.existsSync(), isFalse);
    expect(FileDownloader.partOf(target).lengthSync(), lessThan(bytes.length));
  });
}
