import 'dart:convert';

import 'package:nutq/features/jobs/domain/services/job_estimate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps this device's measured [JobRates] across launches, as one JSON value.
class SharedPreferencesJobRatesStore implements JobRatesStore {
  SharedPreferencesJobRatesStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'job_rates';

  @override
  JobRates load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const JobRates();
    try {
      final json = jsonDecode(raw);
      return json is Map<String, Object?> ? JobRates.fromJson(json) : const JobRates();
    } on FormatException {
      return const JobRates();
    }
  }

  @override
  Future<void> save(JobRates rates) => _prefs.setString(_key, jsonEncode(rates.toJson()));
}
