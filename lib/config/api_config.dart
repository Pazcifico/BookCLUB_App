
class ApiConfig {
  static String get baseUrl => const String.fromEnvironment('API_DOMAIN_API', defaultValue: '');
}

