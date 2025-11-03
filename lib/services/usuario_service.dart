import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class UsuarioService {
  final String baseUrl = '';

  Future<Usuario> getUsuario(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios/$id'));
    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao carregar usuário');
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/${usuario.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar usuário');
    }
  }
}
