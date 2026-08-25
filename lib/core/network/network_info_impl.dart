import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nutq/core/network/network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    if (await _hasConnection()) return true;

    // connectivity_plus can briefly misreport "none" right after the app
    // resumes from being idle/backgrounded (its platform channel hasn't
    // caught up yet). One short re-check avoids blocking every request
    // with a false "offline" for the rest of the session.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _hasConnection();
  }

  Future<bool> _hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
    _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
}