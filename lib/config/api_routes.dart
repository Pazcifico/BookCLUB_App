import 'api_config.dart';

class ApiRoutes {
  static final String base = ApiConfig.baseUrl;

  // Usuário
  static String signup= "$base/user/api/signup/";
  static String login = "$base/user/api/login/";
  static String logout = "$base/user/api/logout/";
  static String changePassword = "$base/user/api/password/change/";
  static String profile = "$base/user/api/profile/";
  static String resetPassword = "$base/user/api/password/reset/request/";
}
