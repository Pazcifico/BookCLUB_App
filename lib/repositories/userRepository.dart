import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:BookCLUB/config/api_routes.dart';
import 'package:BookCLUB/models/usuario_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/models/resenha_model.dart';
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

      if (token == null) {
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
   *  LISTAR RESENHAS
   * -------------------------------------------------------------------------- */
  Future<List<Resenha>> getResenhas(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      token ??= await refreshToken();
      if (token == null) return [];

      final url = Uri.parse(ApiRoutes.resenhasListar(userId));

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.map((r) => Resenha.fromJson(r)).toList();
        } else {
          return [];
        }
      }

      if (response.statusCode == 401) {
        final newToken = await refreshToken();
        if (newToken == null) return [];
        final retry = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );
        if (retry.statusCode == 200) {
          final bodyRetry = jsonDecode(retry.body);
          if (bodyRetry is List) {
            return bodyRetry.map((r) => Resenha.fromJson(r)).toList();
          } else {
            return [];
          }
        }
      }

      return [];
    } catch (e, s) {
      print("❌ Exceção em getResenhas: $e");
      print("📜 StackTrace:\n$s");
      return [];
    }
  }

  /* --------------------------------------------------------------------------
   *  EDITAR PERFIL (Web + Mobile)
   * -------------------------------------------------------------------------- */
Future<bool> editarPerfil({
  required Profile profile,
  XFile? profilePicture,
  XFile? thumbnail,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    token ??= await refreshToken();
    if (token == null) return false;

    final uri = Uri.parse(ApiRoutes.profile);

    Future<http.Response> sendRequest(String accessToken) async {
      var request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..fields['user'] = profile.userId.toString()   // ⚠ obrigatório
        ..fields['name'] = profile.name ?? ''
        ..fields['bio'] = profile.bio ?? '';

      if (profilePicture != null) {
        final bytes = await profilePicture.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: profilePicture.name,
        ));
      }

      if (thumbnail != null) {
        final bytes = await thumbnail.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'thumbnail',
          bytes,
          filename: thumbnail.name,
        ));
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    // Primeiro envio
    var response = await sendRequest(token);

    // Se 401, tenta refresh e reenviar
    if (response.statusCode == 401) {
      final newToken = await refreshToken();
      if (newToken == null) return false;
      await prefs.setString('access_token', newToken);

      response = await sendRequest(newToken);
    }

    if (response.statusCode == 200) return true;

    print("❌ Erro ao editar perfil (${response.statusCode}): ${response.body}");
    return false;
  } catch (e, s) {
    print("❌ Exceção em editarPerfil: $e");
    print("📜 StackTrace:\n$s");
    return false;
  }
}

 // -------------------------------------------------------
  // Checa se já segue o usuário
  // GET /seguir/<user_id>/
  // -------------------------------------------------------
  Future<bool> checarSegue(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      token ??= await refreshToken();
      if (token == null) return false;

      final url = Uri.parse(ApiRoutes.seguir(userId));
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['seguindo'] ?? false;
      }

      return false;
    } catch (e) {
      print("Erro em checarSegue(): $e");
      return false;
    }
  }

  // -------------------------------------------------------
  // Segue ou deixa de seguir usuário
  // POST = seguir | DELETE = deixar de seguir
  // -------------------------------------------------------
  Future<bool> seguir(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      token ??= await refreshToken();
      if (token == null) return false;

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Primeiro, checa se já segue
      final jaSegue = await checarSegue(userId);
      final url = Uri.parse(ApiRoutes.seguir(userId));
      http.Response response;

      if (jaSegue) {
        response = await http.delete(url, headers: headers);
      } else {
        response = await http.post(url, headers: headers);
      }

      // Se token expirou → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await refreshToken();
        if (newToken == null) return false;
        await prefs.setString('access_token', newToken);
        final newHeaders = {
          'Accept': 'application/json',
          'Authorization': 'Bearer $newToken',
        };

        if (jaSegue) {
          response = await http.delete(url, headers: newHeaders);
        } else {
          response = await http.post(url, headers: newHeaders);
        }
      }

      // Retorna true se a ação foi bem-sucedida
      return response.statusCode == 200;
    } catch (e) {
      print("Erro em seguir(): $e");
      return false;
    }
  }
}
