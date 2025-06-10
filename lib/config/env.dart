class Env {
  static const String _devApiUrl = 'http://172.18.198.206:8080/api/v1';
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: _devApiUrl,
  );
}