import 'package:get_it/get_it.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/models/job_detail_args.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/summarization/data/datasources/gemma_local_datasource.dart';
import 'package:nutq/features/summarization/data/repositories/summarization_repository_impl.dart';
import 'package:nutq/features/summarization/domain/repositories/summarization_repository.dart';
import 'package:nutq/features/summarization/domain/usecases/summarize_transcript.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()));

  sl.registerFactory<JobsCubit>(JobsCubit.new);
  sl.registerFactoryParam<JobDetailCubit, JobDetailArgs, void>(
    (args, _) => JobDetailCubit(
      summarize: sl<SummarizeTranscript>(),
      repository: sl<SummarizationRepository>(),
      transcript: args.text,
      language: args.language,
    ),
  );
  sl.registerFactory<NewJobCubit>(NewJobCubit.new);

  // On-device summarization (Gemma 3 1B IT, LiteRT-LM).
  sl.registerLazySingleton<GemmaLocalDataSource>(GemmaLocalDataSourceImpl.new);
  sl.registerLazySingleton<SummarizationRepository>(
    () => SummarizationRepositoryImpl(dataSource: sl<GemmaLocalDataSource>()),
  );
  sl.registerLazySingleton<SummarizeTranscript>(
    () => SummarizeTranscript(repository: sl<SummarizationRepository>()),
  );
}
