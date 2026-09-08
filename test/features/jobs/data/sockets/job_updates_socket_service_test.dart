import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/data/sockets/job_updates_socket_service.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Minimal in-memory [WebSocketChannel] the test drives directly — feed
/// frames with [addServerMessage], simulate a server-initiated close with
/// [closeFromServer]. `with StreamChannelMixin` supplies the default
/// pipe/transform/cast implementations [WebSocketChannel] inherits from
/// [StreamChannel] so only the channel-specific members need faking.
class _FakeChannel with StreamChannelMixin<dynamic> implements WebSocketChannel {
  final _incoming = StreamController<dynamic>.broadcast();
  final sunk = <dynamic>[];

  @override
  int? closeCode;
  @override
  String? closeReason;
  @override
  String? protocol;
  @override
  Future<void> get ready => Future.value();

  @override
  Stream get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _FakeSink(this);

  void addServerMessage(Map<String, dynamic> json) => _incoming.add(jsonEncode(json));

  void closeFromServer(int code, [String? reason]) {
    closeCode = code;
    closeReason = reason;
    unawaited(_incoming.close());
  }

  void errorFromServer(Object error) => _incoming.addError(error);
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this._channel);
  final _FakeChannel _channel;

  @override
  void add(dynamic event) => _channel.sunk.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) => stream.forEach(add);

  @override
  Future close([int? closeCode, String? closeReason]) async {}

  @override
  Future get done => Future.value();
}

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://api.example.com/v1'));
  });

  test('parses a snapshot frame and reports connected once received', () {
    fakeAsync((async) {
      final channel = _FakeChannel();
      final events = <JobUpdateEvent>[];
      final statuses = <JobConnectionStatus>[];

      final service = JobUpdatesSocketServiceImpl(
        dio: dio,
        channelFactory: (_) => channel,
      );

      service.connect('job-1').listen(events.add);
      service.connectionStatus.listen(statuses.add);
      async.flushMicrotasks();

      channel.addServerMessage({
        'type': 'snapshot',
        'job': {
          'id': 'job-1',
          'status': 'processing',
          'source_type': 'upload',
          'language': 'ar',
          'created_at': '2026-01-01T00:00:00.000Z',
          'updated_at': '2026-01-01T00:00:00.000Z',
        },
      });
      async.flushMicrotasks();

      expect(events, hasLength(1));
      expect(events.single, isA<JobUpdateSnapshot>());
      expect(statuses, contains(JobConnectionStatus.connected));

      service.disconnect();
    });
  });

  test('reconnects with backoff on a transient (non-clean) close', () {
    fakeAsync((async) {
      var attempt = 0;
      final channels = <_FakeChannel>[];

      final service = JobUpdatesSocketServiceImpl(
        dio: dio,
        channelFactory: (_) {
          attempt++;
          final channel = _FakeChannel();
          channels.add(channel);
          return channel;
        },
      );

      final statuses = <JobConnectionStatus>[];
      service.connectionStatus.listen(statuses.add);
      service.connect('job-1').listen((_) {});
      async.flushMicrotasks();
      expect(attempt, 1);

      // Transient close (no explicit code) — should schedule a reconnect.
      channels.first.closeFromServer(1006);
      async.flushMicrotasks();
      expect(statuses, contains(JobConnectionStatus.reconnecting));

      async.elapse(const Duration(seconds: 2));
      expect(attempt, 2);

      service.disconnect();
    });
  });

  test('a done/error frame is a clean close — no reconnect attempted', () {
    fakeAsync((async) {
      var attempt = 0;
      final channel = _FakeChannel();

      final service = JobUpdatesSocketServiceImpl(
        dio: dio,
        channelFactory: (_) {
          attempt++;
          return channel;
        },
      );

      service.connect('job-1').listen((_) {});
      async.flushMicrotasks();

      channel.addServerMessage({'type': 'done', 'job': _jobJson('job-1', 'completed')});
      async.flushMicrotasks();
      channel.closeFromServer(1000);
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 40));
      expect(attempt, 1); // never reconnected

      service.disconnect();
    });
  });

  test('a 4404 close surfaces error(code: 4404) and does not reconnect', () {
    fakeAsync((async) {
      var attempt = 0;
      final channel = _FakeChannel();
      final events = <JobUpdateEvent>[];

      final service = JobUpdatesSocketServiceImpl(
        dio: dio,
        channelFactory: (_) {
          attempt++;
          return channel;
        },
      );

      service.connect('job-1').listen(events.add);
      async.flushMicrotasks();

      channel.closeFromServer(4404);
      async.flushMicrotasks();

      expect(events, hasLength(1));
      final event = events.single as JobUpdateError;
      expect(event.code, '4404');

      async.elapse(const Duration(seconds: 40));
      expect(attempt, 1);

      service.disconnect();
    });
  });
}

Map<String, dynamic> _jobJson(String id, String status) => {
  'id': id,
  'status': status,
  'source_type': 'upload',
  'language': 'ar',
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-01-01T00:00:00.000Z',
};
