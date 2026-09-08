import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/ws/ws_url_builder.dart';

void main() {
  group('buildJobSocketUri', () {
    test('maps http -> ws and appends the job path', () {
      final uri = buildJobSocketUri('http://127.0.0.1:8000/v1', 'job-1');

      expect(uri.scheme, 'ws');
      expect(uri.host, '127.0.0.1');
      expect(uri.port, 8000);
      expect(uri.path, '/v1/jobs/job-1/ws');
    });

    test('maps https -> wss', () {
      final uri = buildJobSocketUri('https://api.nutq.app/v1', 'job-2');

      expect(uri.scheme, 'wss');
      expect(uri.path, '/v1/jobs/job-2/ws');
    });

    test('handles a base URL with a trailing slash', () {
      final uri = buildJobSocketUri('http://127.0.0.1:8000/v1/', 'job-3');

      expect(uri.path, '/v1/jobs/job-3/ws');
    });
  });
}
