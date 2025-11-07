import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:BookCLUB/config/api_routes.dart';
import 'package:BookCLUB/models/usuario_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  /// Cadastro de usuário
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

      // 🔹 Pega o token de autenticação
      final token = data['token'];
      if (token == null) throw Exception("Token ausente na resposta da API.");

      // 🔹 Salva o token localmente (para login automático, etc)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      // 🔹 Retorna o usuário criado
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


  /// Login de usuário
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

      if (response.statusCode == 200 && data['token'] != null) {
        final token = data['token'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return token;
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

  /// Logout do usuário
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final url = Uri.parse(ApiRoutes.logout);

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      await prefs.remove('auth_token');
    } catch (e, s) {
      print("❌ Exceção ao fazer logout: $e");
      print("📜 StackTrace completo:\n$s");
    }
  }

  /// Obter perfil do usuário autenticado
  Future<Profile?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print("⚠️ Nenhum token salvo — usuário não autenticado.");
        return null;
      }

      final url = Uri.parse(ApiRoutes.profile);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Profile.fromJson(data);
      } else {
        print("❌ Erro ao buscar perfil: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, s) {
      print("❌ Exceção ao buscar perfil: $e");
      print("📜 StackTrace completo:\n$s");
      return null;
    }
  }

  /// Trocar senha
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse(ApiRoutes.changePassword);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Erro ao alterar senha: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e, s) {
      print("❌ Exceção ao alterar senha: $e");
      print("📜 StackTrace completo:\n$s");
      return false;
    }
  }

  /// Solicitar reset de senha
  Future<bool> resetPasswordRequest(String email) async {
    try {
      final url = Uri.parse(ApiRoutes.resetPassword);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Erro ao solicitar reset: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e, s) {
      print("❌ Exceção ao solicitar reset de senha: $e");
      print("📜 StackTrace completo:\n$s");
      return false;
    }
  }
}
