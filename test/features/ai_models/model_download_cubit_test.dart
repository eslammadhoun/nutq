import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/errors/app_error.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';

import 'support/fake_model_repository.dart';

void main() {
  test('sums the packs it shows and follows their downloads', () async {
    final models = FakeModelRepository(ready: {'moonshine-en'});
    final cubit = ModelDownloadCubit(models, models.packs.take(2).toList());
    addTearDown(cubit.close);

    expect(cubit.state.totalBytes, (600 + 31) * 1024 * 1024);
    expect(cubit.state.receivedBytes, 0);
    expect(cubit.state.isReady, isFalse);

    cubit.download();
    await pumpEventQueue();
    expect(models.downloads, ['gemma', 'moonshine-ar']);
    expect(cubit.state.isDownloading, isTrue);
    expect(cubit.state.progress, closeTo(0.5, 0.01));

    cubit.pause();
    await pumpEventQueue();
    expect(cubit.state.isDownloading, isFalse);
    expect(cubit.state.receivedBytes, greaterThan(0), reason: 'kept for resuming');

    models.fail('gemma', AppError.modelDownloadNetwork);
    await pumpEventQueue();
    expect(cubit.state.error, AppError.modelDownloadNetwork);

    models
      ..finish('gemma')
      ..finish('moonshine-ar');
    await pumpEventQueue();
    expect(cubit.state.isReady, isTrue);
    expect(cubit.state.error, isNull);
  });
}
