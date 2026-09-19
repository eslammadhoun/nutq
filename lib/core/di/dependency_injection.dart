import 'package:get_it/get_it.dart';
import 'package:nutq/core/locale/locale_cubit.dart';
import 'package:nutq/core/preferences/app_preferences.dart';
import 'package:nutq/features/jobs/presentation/cubit/job_detail_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/models/presentation/cubit/models_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<AppPreferences>()));

  sl.registerFactory<JobsCubit>(JobsCubit.new);
  sl.registerFactory<JobDetailCubit>(JobDetailCubit.new);
  sl.registerFactory<NewJobCubit>(NewJobCubit.new);
  sl.registerFactory<ModelsCubit>(ModelsCubit.new);
}
