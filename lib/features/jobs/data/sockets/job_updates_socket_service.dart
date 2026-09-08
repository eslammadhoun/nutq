import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nutq/core/network/ws/ws_url_builder.dart';
import 'package:nutq/features/jobs/data/sockets/job_update_message_mapper.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Close code the `nutq_api` `/jobs/{id}/ws` endpoint uses for
/// not-found-or-not-yours.
const _notFoundCloseCode = 4404;

/// Lifecycle of the job-updates socket, surfaced to the cubit so it can
/// fall back to polling once the retry budget is exhausted.
enum JobConnectionStatus { idle, connecting, connected, reconnecting, disconnected }

/// Live-update transport for a single job's `/jobs/{id}/ws` stream.
///
/// One instance is scoped to one Job Detail screen (registered as a GetIt
/// factory, never a singleton) — a stray second screen must not tear down
/// another job's connection.
abstract interface class JobUpdatesSocketService {
  /// Opens the socket for [jobId] and returns the event stream. Internally
  /// reconnects with backoff on transient failures until the retry budget
  /// is exhausted (see [connectionStatus]).
  Stream<JobUpdateEvent> connect(String jobId);

  Stream<JobConnectionStatus> get connectionStatus;

  /// Tears down the socket and any pending reconnect attempt. Terminal —
  /// this instance cannot be reused afterwards.
  void disconnect();
}

class JobUpdatesSocketServiceImpl implements JobUpdatesSocketService {
  JobUpdatesSocketServiceImpl({
    required this._dio,
    WebSocketChannel Function(Uri uri)? channelFactory,
    this._maxAttempts = 8,
    this._baseBackoff = const Duration(milliseconds: 500),
    this._maxBackoff = const Duration(seconds: 30),
    Random? random,
  }) : _channelFactory = channelFactory ?? WebSocketChannel.connect,
       _random = random ?? Random();

  final Dio _dio;
  final WebSocketChannel Function(Uri uri) _channelFactory;
  final int _maxAttempts;
  final Duration _baseBackoff;
  final Duration _maxBackoff;
  final Random _random;

  final _eventsController = StreamController<JobUpdateEvent>.broadcast();
  final _statusController = StreamController<JobConnectionStatus>.broadcast();

  String? _jobId;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _reconnectTimer;
  int _attempt = 0;

  /// Set the instant a `done`/`error` **frame** is parsed (a clean,
  /// server-initiated close) so `onDone`/`onError` never mistake it for a
  /// transient disconnect and retry.
  bool _closedCleanly = false;
  bool _disposed = false;

  @override
  Stream<JobUpdateEvent> connect(String jobId) {
    _jobId = jobId;
    _attempt = 0;
    _closedCleanly = false;
    unawaited(_openSocket());
    return _eventsController.stream;
  }

  @override
  Stream<JobConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  void disconnect() {
    _disposed = true;
    _reconnectTimer?.cancel();
    unawaited(_channelSubscription?.cancel());
    _channel?.sink.close();
    if (!_eventsController.isClosed) unawaited(_eventsController.close());
    if (!_statusController.isClosed) unawaited(_statusController.close());
  }

  Future<void> _openSocket() async {
    if (_disposed || _jobId == null) return;

    _emitStatus(_attempt == 0 ? JobConnectionStatus.connecting : JobConnectionStatus.reconnecting);

    final uri = buildJobSocketUri(_dio.options.baseUrl, _jobId!);

    try {
      final channel = _channelFactory(uri);
      _channel = channel;
      unawaited(_channelSubscription?.cancel());
      _channelSubscription = channel.stream.listen(
        _onData,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    if (_disposed) return;
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      _log('Malformed WS frame (not JSON): dropped');
      return;
    }

    final event = json.toJobUpdateEvent();
    if (event == null) return;

    switch (event) {
      case JobUpdateSnapshot():
        // Round-trip proven healthy — reset the backoff counter.
        _attempt = 0;
        _emitStatus(JobConnectionStatus.connected);
      case JobUpdateDone():
      case JobUpdateError():
        _closedCleanly = true;
      default:
        break;
    }

    if (!_eventsController.isClosed) _eventsController.add(event);
  }

  Future<void> _onDone() async {
    if (_disposed) return;
    if (_closedCleanly) return;

    final code = _channel?.closeCode;
    if (code == _notFoundCloseCode) {
      _closedCleanly = true;
      if (!_eventsController.isClosed) {
        _eventsController.add(
          const JobUpdateEvent.error(message: 'not_found', code: '$_notFoundCloseCode'),
        );
      }
      _emitStatus(JobConnectionStatus.disconnected);
      return;
    }

    _scheduleReconnect();
  }

  void _onError(Object error) {
    if (_disposed || _closedCleanly) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _closedCleanly) return;
    _attempt++;
    if (_attempt > _maxAttempts) {
      _emitStatus(JobConnectionStatus.disconnected);
      return;
    }

    _emitStatus(JobConnectionStatus.reconnecting);
    final exponentialMs = _baseBackoff.inMilliseconds * pow(2, _attempt - 1);
    final cappedMs = min(exponentialMs.toInt(), _maxBackoff.inMilliseconds);
    final jitterMs = _random.nextInt(cappedMs ~/ 2 + 1);
    final delay = Duration(milliseconds: cappedMs + jitterMs);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => unawaited(_openSocket()));
  }

  void _emitStatus(JobConnectionStatus status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void _log(String message) {
    if (!kReleaseMode) debugPrint('[JobUpdatesSocket] $message');
  }
}
