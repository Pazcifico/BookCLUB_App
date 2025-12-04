import 'package:BookCLUB/models/livro_model.dart';
import 'package:BookCLUB/models/profile_model.dart';


import 'livro_model.dart';
import 'profile_model.dart';

class Resenha {
  final int id;
  final Profile usuario;
  final Livro livro;
  final int nota;
  final String comentario;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Resenha({
    required this.id,
    required this.usuario,
    required this.livro,
    required this.nota,
    required this.comentario,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Resenha.fromJson(Map<String, dynamic> json) {
    return Resenha(
      id: json['id'],
      usuario: Profile.fromJson(json['usuario']),
      livro: Livro.fromJson(json['livro']),
      nota: json['nota'],
      comentario: json['comentario'],
      criadoEm: DateTime.parse(json['criado_em']),
      atualizadoEm: DateTime.parse(json['atualizado_em']),
    );
  }
}


