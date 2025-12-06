import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/config/api_routes.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/models/topico_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/models/mensagem_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:BookCLUB/models/livro_model.dart';
import 'package:BookCLUB/config/api_config.dart';

class GrupoRepository {
  final UserRepository _userRepository = UserRepository();

  Future<List<Grupo>> getGruposUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return [];
      }

      final url = Uri.parse(ApiRoutes.chats);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List data = responseData['chats'];
        return data.map((json) => Grupo.fromJson(json)).toList();
      }

      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return [];

        final retry = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        if (retry.statusCode == 200) {
          final responseData = jsonDecode(retry.body);
          final List data = responseData['chats'];
          return data.map((json) => Grupo.fromJson(json)).toList();
        }
      }

      print("Erro ao buscar grupos: ${response.statusCode}");
      return [];
    } catch (e, s) {
      print("Erro no getGruposUsuario: $e");
      print("StackTrace completo:\n$s");
      return [];
    }
  }

  Future<List<dynamic>> search({
    required String query,
    required String tipo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return [];
      }

      final url = Uri.parse('${ApiRoutes.search}?q=$query&tipo=$tipo');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Se 401, tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return [];

        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List data = responseData['results'];

        if (tipo == 'grupo') {
          return data.map((json) => Grupo.fromJson(json)).toList();
        } else {
          return data.map((json) => Profile.fromJson(json)).toList();
        }
      } else {
        print("Erro na busca: ${response.statusCode}");
        return [];
      }
    } catch (e, s) {
      print("Erro na busca: $e");
      print("StackTrace:\n$s");
      return [];
    }
  }

  Future<List<Topico>> getTopicosGrupo(int grupoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return [];
      }

      final url = Uri.parse(ApiRoutes.topicos(grupoId));
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Se der 401 -> tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return [];

        response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // resposta é um array direto
        final List data = jsonData;

        return data.map((item) => Topico.fromJson(item)).toList();
      }

      print("Erro ao buscar tópicos: ${response.statusCode}");
      return [];
    } catch (e, s) {
      print("Erro no getTopicosGrupo: $e");
      print(s);
      return [];
    }
  }

  Future<List<Profile>> selecionarMembros() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Se token expirou → tenta refresh
      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return [];
      }

      final url = Uri.parse(ApiRoutes.membros);
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Se deu 401 → token expirado → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return [];

        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );
      }

      // Sucesso
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Profile.fromJson(json)).toList();
      }

      print("Erro ao buscar membros: ${response.statusCode}");
      return [];
    } catch (e, s) {
      print("Erro no selecionarMembros: $e");
      print("StackTrace:\n$s");
      return [];
    }
  }

Future<bool> criarGrupo({
  required Grupo grupo,
  required List<int> membros,
  XFile? imagem,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      token = await _userRepository.refreshToken();
      if (token == null) return false;
    }

    Future<http.Response> enviar(String tokenAtual) async {
      final uri = Uri.parse(ApiRoutes.grupoCriar);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $tokenAtual';

      // CAMPOS NORMAIS
      request.fields['nome'] = grupo.nome?.trim() ?? '';
      request.fields['descricao'] = grupo.descricao?.trim() ?? '';
      request.fields['privado'] = grupo.privado.toString();

      // LISTA DE MEMBROS (só envia se houver)
      if (membros.isNotEmpty) {
        request.fields['membros'] = jsonEncode(membros);
      }

      // IMAGEM
      if (imagem != null) {
        if (kIsWeb) {
          final bytes = await imagem.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes('imagem', bytes, filename: imagem.name),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('imagem', imagem.path),
          );
        }
      }

      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    }

    // --------------------------
    // 1️⃣ PRIMEIRA TENTATIVA
    // --------------------------
    http.Response response = await enviar(token);

    // --------------------------
    // 2️⃣ SE 401 → REFRESH TOKEN
    // --------------------------
    if (response.statusCode == 401) {
      print("Token expirado — tentando refreshToken...");

      final newToken = await _userRepository.refreshToken();
      if (newToken == null) return false;

      prefs.setString('access_token', newToken);

      // tenta de novo com o novo token
      response = await enviar(newToken);
    }

    // --------------------------
    // 3️⃣ RESULTADO FINAL
    // --------------------------
    if (response.statusCode == 201) {
      return true;
    }

    print("Erro ao criar grupo: ${response.statusCode} — ${response.body}");
    return false;

  } catch (e, s) {
    print("Erro no criarGrupo: $e");
    print(s);
    return false;
  }
}


  Future<bool> editarGrupo({
    required Grupo grupo,
    XFile? imagem,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return false;
      }

      final uri = Uri.parse(ApiRoutes.grupoEditar(grupo.id!));

      final request = http.MultipartRequest("PUT", uri);
      request.headers["Authorization"] = "Bearer $token";

      // --------------------------
      // CAMPOS NORMAIS
      // --------------------------
      request.fields["nome"] = grupo.nome?.trim() ?? "";
      request.fields["descricao"] = grupo.descricao?.trim() ?? "";
      request.fields["privado"] = grupo.privado.toString();

      // --------------------------
      // IMAGEM
      // --------------------------
      if (imagem != null) {
        if (kIsWeb) {
          final bytes = await imagem.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              "imagem",
              bytes,
              filename: imagem.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              "imagem",
              imagem.path,
            ),
          );
        }
      }

      // --------------------------
      // ENVIA REQUEST
      // --------------------------
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print(
          "Erro ao editar grupo: ${response.statusCode} — ${response.body}");
      return false;
    } catch (e, s) {
      print("Erro no editarGrupo: $e");
      print(s);
      return false;
    }
  }

  Future<List<Mensagem>> getMensagens(int topicoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Se o token expirou → tenta refresh
      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return [];
      }

      final url = Uri.parse(ApiRoutes.mensagens(topicoId));

      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Se 401 → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return [];

        response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );
      }

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((json) => Mensagem.fromJson(json)).toList()
          ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
      }

      print("Erro ao buscar mensagens: ${response.statusCode}");
      return [];
    } catch (e, s) {
      print("Erro no getMensagens: $e");
      print(s);
      return [];
    }
  }

  Future<bool> sairDoGrupo(int grupoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Se token expirou → tenta refresh
      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return false;
      }

      final url = Uri.parse(ApiRoutes.grupoSair(grupoId));

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Se 401 → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return false;

        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      print(
          "Erro ao sair do grupo: ${response.statusCode} — ${response.body}");
      return false;
    } catch (e, s) {
      print("Erro no sairDoGrupo: $e");
      print(s);
      return false;
    }
  }

  Future<bool> entrarNoGrupo(int grupoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Se o token expirou → tenta refresh
      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return false;
      }

      final url = Uri.parse(ApiRoutes.grupoEntrar(grupoId));

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Se 401 → token expirado → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return false;

        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print(
          "Erro ao entrar no grupo: ${response.statusCode} — ${response.body}");
      return false;
    } catch (e, s) {
      print("Erro no entrarNoGrupo: $e");
      print(s);
      return false;
    }
  }

  Future<bool> addMembros(int grupoId, List<int> usuarioIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Se token expirou → tenta refresh
      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return false;
      }

      final url = Uri.parse(ApiRoutes.grupoAddMembros(grupoId));

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "membros": usuarioIds, 
        }),
      );

      // Se 401 → tenta refresh
      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return false;

        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
          body: jsonEncode({
            "membros": usuarioIds,
          }),
        );
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      }

      print(
          "Erro ao adicionar membros: ${response.statusCode} — ${response.body}");
      return false;
    } catch (e, s) {
      print("Erro no addMembros: $e");
      print(s);
      return false;
    }
  }

  Future<List<Livro>> searchLivro(String query) async {
    try {
      final url = Uri.parse("${ApiConfig.bookUrl}?q=$query&maxResults=20");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data["items"] ?? [];

        return items.map((item) => Livro.fromGoogleJson(item)).toList();
      }

      print("Erro ao buscar livros: ${response.statusCode}");
      return [];
    } catch (e, s) {
      print("Erro no searchLivro: $e");
      print("Stack:\n$s");
      return [];
    }
  }

  Future<bool> criarTopicoComLivro({
    required int grupoId,
    required Livro livro,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        token = await _userRepository.refreshToken();
        if (token == null) return false;
      }

      final url = Uri.parse(ApiRoutes.topicoCriar(grupoId));

      final Map<String, dynamic> bodyData = {
        "livro": livro.toJson(),
      };

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 401) {
        final newToken = await _userRepository.refreshToken();
        if (newToken == null) return false;

        response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
          body: jsonEncode(bodyData),
        );
      }

      if (response.statusCode == 201) {
        print("Tópico criado com sucesso!");
        return true;
      }

      print("Erro ao criar tópico: ${response.statusCode}");
      print("Body enviado: $bodyData");
      print("Resposta: ${response.body}");
      return false;
    } catch (e, s) {
      print("Erro no criarTopicoComLivro: $e");
      print(s);
      return false;
    }
  }
}
