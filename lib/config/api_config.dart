
class ApiConfig {
  static String get baseUrl => const String.fromEnvironment('API_DOMAIN_API', defaultValue: '');

  static String get websocketBase {
    if (baseUrl.startsWith("https")) {
      return baseUrl.replaceFirst("https", "wss");
    } else {
      return baseUrl.replaceFirst("http", "ws");
    }
  }
}

