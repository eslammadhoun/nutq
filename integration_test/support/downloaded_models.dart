import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/ai_models/data/model_manifest.dart';
import 'package:nutq/features/ai_models/data/model_repository_impl.dart';
import 'package:nutq/features/ai_models/data/model_storage.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';

/// The app's model store with [kinds] downloaded, as the app does it: models
/// are no longer bundled, so a test on a fresh install fetches them first
/// (and later runs find them on disk).
Future<ModelRepository> downloadedModels(Set<ModelKind> kinds) async {
  final models = ModelRepositoryImpl(
    loadPacks: ModelManifest.load,
    storage: const PlatformModelStorage(),
  );
  await models.init();
  final wanted = [
    for (final pack in models.packs)
      if (kinds.contains(pack.kind)) pack.id,
  ];
  await models.download(wanted);
  for (final id in wanted) {
    expect(models.statuses[id]!.isReady, isTrue, reason: 'downloading $id');
  }
  return models;
}

/// The downloaded Moonshine folder for each language, for
/// `MoonshineSpeechRecognizer(modelPath:)`.
Future<String Function(ContentLanguage)> downloadedMoonshine() async {
  final models = await downloadedModels({ModelKind.transcriber});
  return (ContentLanguage language) => models.directoryOf(models.transcriberFor(language).id);
}
