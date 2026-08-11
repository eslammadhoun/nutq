import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutq/core/network/dio_client.dart';
import 'package:nutq/core/network/token_storage.dart';
import 'package:nutq/core/preferences/app_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));

  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());

  sl.registerLazySingleton<Dio>(
    () => buildDio(
      tokenStorage: sl<TokenStorage>(),
      onSessionExpired: () => sl<AppPreferences>().setLoggedIn(false),
    ),
  );
}
