import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:BookCLUB/config/api_routes.dart';
import 'package:BookCLUB/models/usuario_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  /* --------------------------------------------------------------------------
   *  CADASTRO DE USUÁRIO
   * -------------------------------------------------------------------------- */
  Future<Usuario?> registerUser({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final url = Uri.parse(ApiRoutes.signup);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final access = data['tokens']?['access'];
        final refresh = data['tokens']?['refresh'];

        if (access == null || refresh == null) {
          throw Exception("Tokens ausentes na resposta da API.");
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', access);
        await prefs.setString('refresh_token', refresh);

        return Usuario.fromJson(data['user']);
      } else {
        print("❌ Erro ao registrar usuário: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, s) {
      print("❌ Exceção ao registrar usuário: $e");
      print("📜 StackTrace completo:\n$s");
      return null;
    }
  }

  /* --------------------------------------------------------------------------
   *  LOGIN
   * -------------------------------------------------------------------------- */
  Future<String?> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiRoutes.login);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameOrEmail,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['tokens']?['access'] != null &&
          data['tokens']?['refresh'] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('access_token', data['tokens']['access']);
        await prefs.setString('refresh_token', data['tokens']['refresh']);

        return data['tokens']['access'];
      } else {
        print("❌ Erro de login: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, s) {
      print("❌ Exceção ao tentar login: $e");
      print("📜 StackTrace completo:\n$s");
      return null;
    }
  }

  /* --------------------------------------------------------------------------
   *  REFRESH TOKEN
   * -------------------------------------------------------------------------- */
  Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString('refresh_token');

      if (refresh == null) return null;

      final url = Uri.parse(ApiRoutes.refresh);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];

        if (newAccess != null) {
          await prefs.setString('access_token', newAccess);
          return newAccess;
        }
      }

      return null;
    } catch (e) {
      print("❌ Erro ao atualizar token: $e");
      return null;
    }
  }

  /* --------------------------------------------------------------------------
   *  LOGOUT
   * -------------------------------------------------------------------------- */
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString('refresh_token');
      if (refresh == null) return;

      final url = Uri.parse(ApiRoutes.logout);

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } catch (e, s) {
      print("❌ Exceção ao fazer logout: $e");
      print("📜 StackTrace completo:\n$s");
    }
  }

  /* --------------------------------------------------------------------------
   *  PERFIL DO USUÁRIO
   * -------------------------------------------------------------------------- */
  Future<Profile?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      print("🔍 TOKEN SALVO: $token");

      if (token == null) {
        print("⚠ Nenhum token encontrado, tentando refresh...");
        token = await refreshToken();
        if (token == null) return null;
      }

      final url = Uri.parse(ApiRoutes.profile);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(jsonDecode(response.body));
      }

      // ❌ Token expirado → tentar refresh automático
      if (response.statusCode == 401) {
        final newToken = await refreshToken();
        if (newToken == null) return null;

        final retry = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        if (retry.statusCode == 200) {
          return Profile.fromJson(jsonDecode(retry.body));
        }
      }

      print("❌ Erro ao buscar perfil: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e, s) {
      print("❌ Exceção ao buscar perfil: $e");
      print("📜 StackTrace completo:\n$s");
      return null;
    }
  }

  /* --------------------------------------------------------------------------
   *  ALTERAR SENHA
   * -------------------------------------------------------------------------- */
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final url = Uri.parse(ApiRoutes.changePassword);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e, s) {
      print("❌ Exceção ao alterar senha: $e");
      print("📜 StackTrace completo:\n$s");
      return false;
    }
  }

  /* --------------------------------------------------------------------------
   *  RESET DE SENHA
   * -------------------------------------------------------------------------- */
  Future<bool> resetPasswordRequest(String email) async {
    try {
      final url = Uri.parse(ApiRoutes.resetPassword);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e, s) {
      print("❌ Exceção ao solicitar reset de senha: $e");
      print("📜 StackTrace completo:\n$s");
      return false;
    }
  }
}
