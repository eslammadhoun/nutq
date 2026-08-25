import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioConfig {
  const DioConfig({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/v1',
    ),
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers = const {'Content-Type': 'application/json'},
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, dynamic> headers;

  BaseOptions get baseOptions => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
    headers: headers,
  );

  /// Fail fast at startup instead of letting every request silently fail
  /// behind ATS/cleartext rules — catches a forgotten
  /// `--dart-define=API_BASE_URL=https://…` leaking the localhost debug
  /// default into a release build.
  ///
  /// Deliberately NOT a Dart `assert` — asserts are stripped from release
  /// builds, which is exactly where this check must run.
  static void ensureSecureBaseUrl(String baseUrl, {bool? isRelease}) {
    final release = isRelease ?? kReleaseMode;
    if (!release) return;
    if (Uri.tryParse(baseUrl)?.scheme != 'https') {
      throw StateError(
        'API_BASE_URL must use HTTPS in release builds '
        '(got "$baseUrl"). Pass '
        '--dart-define=API_BASE_URL=https://<host>/v1',
      );
    }
  }
}
