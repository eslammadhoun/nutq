import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/network/dio/dio_config.dart';

void main() {
  group('DioConfig.ensureSecureBaseUrl', () {
    test('release build rejects the localhost debug default', () {
      expect(
        () => DioConfig.ensureSecureBaseUrl(
          'http://127.0.0.1:8000/v1',
          isRelease: true,
        ),
        throwsStateError,
      );
    });

    test('release build rejects any cleartext http URL', () {
      expect(
        () => DioConfig.ensureSecureBaseUrl(
          'http://api.nutq.example.com/v1',
          isRelease: true,
        ),
        throwsStateError,
      );
    });

    test('release build rejects an empty URL', () {
      expect(
        () => DioConfig.ensureSecureBaseUrl('', isRelease: true),
        throwsStateError,
      );
    });

    test('release build accepts https URLs', () {
      expect(
        () => DioConfig.ensureSecureBaseUrl(
          'https://api.nutq.example.com/v1',
          isRelease: true,
        ),
        returnsNormally,
      );
    });

    test('debug builds allow http (local development)', () {
      expect(
        () => DioConfig.ensureSecureBaseUrl(
          'http://192.168.1.20:8000/v1',
          isRelease: false,
        ),
        returnsNormally,
      );
    });
  });
}
