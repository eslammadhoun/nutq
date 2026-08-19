class DioConfig {
  final String baseUrl;
  final Duration connectTimeOut;
  final Duration reciveTimeOut;
  final Duration sendTimeOut;
  final Map<String, String> headers;

  const DioConfig({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://192.168.1.1:8000/v1',
    ),

    this.headers = const {'Content-Type': 'application/json'},
    this.connectTimeOut = const Duration(seconds: 15),
    this.reciveTimeOut = const Duration(seconds: 15),
    this.sendTimeOut = const Duration(seconds: 30),
  });
}
