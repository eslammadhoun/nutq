import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/ml/models/llm_model_spec.dart';
import 'package:nutq/core/ml/models/model_download_service.dart';
import 'package:nutq/core/ml/models/whisper_model_spec.dart';
import 'package:nutq/core/network/error/api_error.dart';
import 'package:nutq/core/network/result/api_result.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('ModelDownloadService', () {
    late AppDatabase db;
    late Directory tempDir;
    late _MockDio dio;
    late ModelDownloadService service;

    setUpAll(() {
      registerFallbackValue(RequestOptions(path: ''));
    });

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp('nutq_model_dl_test');
      dio = _MockDio();
      service = ModelDownloadService(
        dio: dio,
        modelsDao: db.modelsDao,
        supportDirectory: () async => tempDir,
      );
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('download writes the file, records it, and reports progress', () async {
      final progressValues = <double>[];

      when(
        () => dio.download(
          any(),
          any(),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        final savePath = invocation.positionalArguments[1] as String;
        final bytes = List<int>.filled(1000, 1);
        await File(savePath).writeAsBytes(bytes);
        final onProgress = invocation.namedArguments[#onReceiveProgress] as void Function(int, int)?;
        onProgress?.call(500, 1000);
        onProgress?.call(1000, 1000);
        return Response<void>(requestOptions: RequestOptions(path: savePath), statusCode: 200);
      });

      final result = await service.download(WhisperModelSpec.base, onProgress: progressValues.add);

      final row = switch (result) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('download failed: $error'),
      };

      expect(row.modelId, 'base');
      expect(row.sizeBytes, 1000);
      expect(await File(row.filePath).exists(), isTrue);
      expect(progressValues, [0.5, 1.0]);

      final stored = await db.modelsDao.getInstalled('base');
      expect(stored, isNotNull);
      expect(stored!.filePath, row.filePath);
    });

    test('download surfaces deviceOffline on a connection error', () async {
      when(
        () => dio.download(
          any(),
          any(),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError),
      );

      final result = await service.download(WhisperModelSpec.small);

      expect(result, isA<Failure<InstalledModelRow>>());
      final error = (result as Failure<InstalledModelRow>).error;
      expect(error, isA<DeviceOfflineError>());
    });

    test('download records an llm-kind row for an LlmModelSpec (shared machinery, not duplicated)', () async {
      when(
        () => dio.download(
          any(),
          any(),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        final savePath = invocation.positionalArguments[1] as String;
        await File(savePath).writeAsBytes(List<int>.filled(1000, 1));
        final onProgress = invocation.namedArguments[#onReceiveProgress] as void Function(int, int)?;
        onProgress?.call(1000, 1000);
        return Response<void>(requestOptions: RequestOptions(path: savePath), statusCode: 200);
      });

      final result = await service.download(LlmModelSpec.oneB);

      final row = switch (result) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('download failed: $error'),
      };

      expect(row.modelId, '1b');
      expect(row.kind, 'llm');
      expect(row.tier, '1b');

      final stored = await db.modelsDao.getInstalled('1b');
      expect(stored, isNotNull);
      expect(stored!.kind, 'llm');
    });

    test('deleteModel removes the file and the DB row', () async {
      when(
        () => dio.download(
          any(),
          any(),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        final savePath = invocation.positionalArguments[1] as String;
        await File(savePath).writeAsBytes(List<int>.filled(1000, 1));
        final onProgress = invocation.namedArguments[#onReceiveProgress] as void Function(int, int)?;
        onProgress?.call(1000, 1000);
        return Response<void>(requestOptions: RequestOptions(path: savePath), statusCode: 200);
      });

      final result = await service.download(WhisperModelSpec.base);
      final row = switch (result) {
        Success(:final data) => data,
        Failure(:final error) => throw StateError('download failed: $error'),
      };

      await service.deleteModel('base');

      expect(await File(row.filePath).exists(), isFalse);
      expect(await db.modelsDao.getInstalled('base'), isNull);
    });
  });
}
