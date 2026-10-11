import 'dart:io';
import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:nutq/core/database/app_database.dart';
import 'package:nutq/core/domain/foreground_gate.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/core/theme/theme_cubit.dart';
import 'package:nutq/core/utils/background_work.dart';
import 'package:nutq/core/utils/lifecycle_foreground_gate.dart';
import 'package:nutq/core/utils/platform_device_status.dart';
import 'package:nutq/features/ai_models/data/model_manifest.dart';
import 'package:nutq/features/ai_models/data/model_repository_impl.dart';
import 'package:nutq/features/ai_models/data/model_storage.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/repositories/model_repository.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';
import 'package:nutq/features/alerts/data/job_alerts_repository.dart';
import 'package:nutq/features/alerts/domain/alerts_repository.dart';
import 'package:nutq/features/alerts/presentation/cubit/alerts_cubit.dart';
import 'package:nutq/features/jobs/data/datasources/jobs_local_datasource.dart';
import 'package:nutq/features/jobs/data/media/platform_media_files.dart';
import 'package:nutq/features/jobs/data/preferences/shared_preferences_job_rates_store.dart';
import 'package:nutq/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:nutq/features/jobs/data/youtube/youtube_subtitle_provider.dart';
import 'package:nutq/features/jobs/domain/entities/job_source_type.dart';
import 'package:nutq/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:nutq/features/jobs/domain/repositories/media_files.dart';
import 'package:nutq/features/jobs/domain/services/background_job.dart';
import 'package:nutq/features/jobs/domain/services/job_runner.dart';
import 'package:nutq/features/jobs/domain/services/job_scheduler.dart';
import 'package:nutq/features/jobs/domain/services/video_subtitles.dart';
import 'package:nutq/features/jobs/domain/sources/media_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/text_transcript_source.dart';
import 'package:nutq/features/jobs/domain/sources/transcript_source_registry.dart';
import 'package:nutq/features/jobs/domain/sources/youtube_transcript_source.dart';
import 'package:nutq/features/jobs/domain/usecases/process_job.dart';
import 'package:nutq/features/jobs/domain/usecases/submit_job.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/profile/data/local_job_storage.dart';
import 'package:nutq/features/profile/domain/job_storage.dart';
import 'package:nutq/features/profile/presentation/cubit/notifications_cubit.dart';
import 'package:nutq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:nutq/features/summarization/data/datasources/flutter_gemma_runtime.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/datasources/llm_runtime.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:nutq/features/transcription/data/ffmpeg_audio_extractor.dart';
import 'package:nutq/features/transcription/data/moonshine_speech_recognizer.dart';
import 'package:nutq/features/transcription/data/platform_background_job.dart';
import 'package:nutq/features/transcription/domain/audio_extractor.dart';
import 'package:nutq/features/transcription/domain/speech_recognizer.dart';
import 'package:nutq/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

/// Registers everything. [openDatabase] and [preferences] exist so tests can
/// supply an in-memory database and mock preferences.
Future<void> setupDI({
  AppDatabase Function()? openDatabase,
  SharedPreferences? preferences,
}) async {
  final prefs = preferences ?? await SharedPreferences.getInstance();
  _registerCore(prefs, openDatabase ?? AppDatabase.new);
  _registerModels();
  _registerSummarization();
  _registerTranscription();
  _registerJobs();
  _registerAlertsAndProfile();
}

void _registerCore(SharedPreferences prefs, AppDatabase Function() openDatabase) {
  sl
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton<AppPreferences>(() => AppPreferences(prefs))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()))
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<AppPreferences>()))
    ..registerLazySingleton<AppDatabase>(openDatabase, dispose: (db) => db.close());
}

/// The AI models, downloaded after install. `main` calls
/// `ModelRepository.init` before the app starts.
void _registerModels() {
  sl
    ..registerLazySingleton<ModelRepository>(
      () => ModelRepositoryImpl(
        loadPacks: ModelManifest.load,
        storage: const PlatformModelStorage(),
      ),
    )
    ..registerFactoryParam<ModelDownloadCubit, List<ModelPack>, void>(
      (packs, _) => ModelDownloadCubit(sl<ModelRepository>(), packs),
    );
}

/// On-device summarization (Gemma 3 1B fine-tuned for Arabic, LiteRT-LM).
void _registerSummarization() {
  sl
    ..registerLazySingleton<LlmRuntime>(
      () => FlutterGemmaRuntime(
        modelPath: () => sl<ModelRepository>().fileOf(sl<ModelRepository>().summarizer.id),
      ),
    )
    ..registerLazySingleton<GemmaLocalDataSource>(
      () => GemmaLocalDataSourceImpl(sl<LlmRuntime>()),
    )
    ..registerLazySingleton<SummarizationRepository>(
      () => SummarizationRepositoryImpl(dataSource: sl<GemmaLocalDataSource>()),
    )
    ..registerLazySingleton<SummarizeTranscript>(
      () => SummarizeTranscript(
        repository: sl<SummarizationRepository>(),
        background: const IsolateBackgroundWork(),
        device: const PlatformDeviceStatus(),
        foreground: _summaryForeground,
      ),
    );
}

/// On-device speech recognition for audio and video jobs.
void _registerTranscription() {
  sl
    ..registerLazySingleton<AudioExtractor>(FfmpegAudioExtractor.new)
    ..registerLazySingleton<SpeechRecognizer>(
      () => MoonshineSpeechRecognizer(
        modelPath: (language) =>
            sl<ModelRepository>().directoryOf(sl<ModelRepository>().transcriberFor(language).id),
      ),
    )
    ..registerLazySingleton<BackgroundJob>(
      () => Platform.isIOS || Platform.isAndroid
          ? PlatformBackgroundJob(
              localizations: _currentLocalizations,
              notifyWhenDone: () => sl<AppPreferences>().notifyWhenDone,
            )
          : const NoBackgroundJob(),
    );
}

/// Where the summary may run. iOS allows no GPU work in the background, so
/// there it waits for the app; Android lets a foreground service (`JobService`)
/// use the GPU, so there it carries on.
final ForegroundGate _summaryForeground = Platform.isAndroid
    ? const AlwaysInForeground()
    : const LifecycleForegroundGate();

/// Strings in the language the app is showing: the user's choice, or the
/// device language when they made none.
AppLocalizations _currentLocalizations() {
  final chosen = sl<LocaleCubit>().state ?? PlatformDispatcher.instance.locale;
  final supported = supportedLocales.any((l) => l.languageCode == chosen.languageCode);
  return lookupAppLocalizations(supported ? Locale(chosen.languageCode) : supportedLocales.first);
}

/// Jobs: storage, the sources that can be processed, and the app-wide queue.
void _registerJobs() {
  sl
    ..registerLazySingleton<JobsLocalDataSource>(
      () => JobsLocalDataSourceImpl(sl<AppDatabase>().jobsDao),
    )
    ..registerLazySingleton<JobsRepository>(
      () => JobsRepositoryImpl(
        sl<JobsLocalDataSource>(),
        newId: () => const Uuid().v4(),
      ),
    )
    // Register a TranscriptSource here to make a new source type usable.
    ..registerLazySingleton<TranscriptSourceRegistry>(
      () => TranscriptSourceRegistry([
        const TextTranscriptSource(),
        // Speech recognition (Moonshine) exists only on iOS; elsewhere the
        // New Job sheet keeps the audio and video tabs disabled.
        if (sl<SpeechRecognizer>().isAvailable)
          for (final type in const [JobSourceType.audio, JobSourceType.video])
            MediaTranscriptSource(
              type: type,
              extractor: sl<AudioExtractor>(),
              recognizer: sl<SpeechRecognizer>(),
              background: sl<BackgroundJob>(),
            ),
        YouTubeTranscriptSource(sl<SubtitleProvider>()),
      ]),
    )
    ..registerLazySingleton<SubtitleProvider>(YouTubeSubtitleProvider.new)
    ..registerLazySingleton<ProcessJob>(
      () => ProcessJob(
        jobs: sl<JobsRepository>(),
        sources: sl<TranscriptSourceRegistry>(),
        summarize: sl<SummarizeTranscript>(),
        summarization: sl<SummarizationRepository>(),
        foreground: _summaryForeground,
        background: sl<BackgroundJob>(),
        rates: SharedPreferencesJobRatesStore(sl<SharedPreferences>()),
      ),
    )
    ..registerLazySingleton<JobRunner>(
      () => JobRunner(
        jobs: sl<JobsRepository>(),
        process: sl<ProcessJob>(),
        media: sl<MediaFiles>(),
        // Free the model's memory once no job has run for a while.
        onIdle: sl<SummarizationRepository>().release,
      ),
      dispose: (runner) => runner.dispose(),
    )
    ..registerLazySingleton<JobScheduler>(() => sl<JobRunner>())
    ..registerLazySingleton<SubmitJob>(
      () => SubmitJob(sl<JobsRepository>(), sl<JobScheduler>()),
    )
    ..registerFactory<JobsCubit>(() => JobsCubit(sl<JobsRepository>()))
    ..registerLazySingleton<MediaFiles>(() => PlatformMediaFiles(newId: () => const Uuid().v4()))
    ..registerFactory<NewJobCubit>(
      () => NewJobCubit(
        sl<SubmitJob>(),
        sl<MediaFiles>(),
        recognizesLink: sl<SubtitleProvider>().recognizes,
        supportedSources: sl<TranscriptSourceRegistry>().supportedTypes,
        missingModels: (type, language) {
          final models = sl<ModelRepository>();
          return [
            for (final pack in models.requiredFor(type, language))
              if (!models.statuses[pack.id]!.isReady) pack,
          ];
        },
      ),
    )
    ..registerFactoryParam<JobDetailCubit, String, void>(
      (jobId, _) => JobDetailCubit(
        repository: sl<JobsRepository>(),
        scheduler: sl<JobScheduler>(),
        jobId: jobId,
      ),
    );
}

/// Alerts (finished jobs) and the Settings tab's storage.
void _registerAlertsAndProfile() {
  sl
    ..registerLazySingleton<AlertsRepository>(
      () => JobAlertsRepository(sl<JobsRepository>(), sl<AppPreferences>()),
      dispose: (repository) => (repository as JobAlertsRepository).dispose(),
    )
    ..registerFactory<AlertsCubit>(() => AlertsCubit(sl<AlertsRepository>()))
    ..registerLazySingleton<JobStorage>(
      () => LocalJobStorage(
        jobs: sl<JobsRepository>(),
        media: sl<MediaFiles>(),
        scheduler: sl<JobScheduler>(),
      ),
    )
    ..registerFactory<ProfileCubit>(() => ProfileCubit(sl<JobStorage>()))
    ..registerFactory<NotificationsCubit>(() => NotificationsCubit(sl<AppPreferences>()));
}
