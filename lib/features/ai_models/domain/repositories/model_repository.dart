import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';

/// The AI models the app downloads after install, and where they stand.
abstract interface class ModelRepository {
  /// Reads the manifest and what is already on disk. Call once, before
  /// anything else.
  Future<void> init();

  /// Every pack the app knows, in manifest order.
  List<ModelPack> get packs;

  /// The Gemma summarizer, which every job needs.
  ModelPack get summarizer;

  /// The Moonshine model that recognizes [language].
  ModelPack transcriberFor(ContentLanguage language);

  /// The status of every pack, by id. Never empty after [init].
  Map<String, ModelPackStatus> get statuses;

  /// [statuses] each time one changes; progress at most a few times a second.
  Stream<Map<String, ModelPackStatus>> get changes;

  /// The packs a job needs: the summarizer always, and the transcriber for
  /// the job's language when it is audio or video.
  List<ModelPack> requiredFor(JobSourceType type, ContentLanguage language);

  /// Downloads [ids] one after another, resuming what was received before.
  /// Packs already ready or queued are skipped. Never throws: a failure is
  /// reported as [ModelPackPhase.failed] on that pack, and the rest go on.
  Future<void> download(Iterable<String> ids);

  /// Stops the download in progress and drops the queue. What was received is
  /// kept for the next [download].
  void cancel();

  /// Removes a pack's files, including a partial download.
  Future<void> delete(String id);

  /// The pack's folder on disk (Moonshine loads a folder).
  String directoryOf(String id);

  /// The path of a single-file pack's file (the Gemma `.litertlm`).
  String fileOf(String id);
}
