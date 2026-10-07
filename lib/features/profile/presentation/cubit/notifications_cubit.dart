import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/core/preferences/app_preferences.dart';

/// The Settings switch for the "Summary ready" notification posted when a job
/// finishes outside the app. The notice that a job is waiting for the app is
/// not affected: the job cannot finish without it.
class NotificationsCubit extends Cubit<bool> {
  NotificationsCubit(this._prefs) : super(_prefs.notifyWhenDone);

  final AppPreferences _prefs;

  Future<void> setEnabled(bool enabled) async {
    emit(enabled);
    await _prefs.setNotifyWhenDone(enabled);
  }
}
