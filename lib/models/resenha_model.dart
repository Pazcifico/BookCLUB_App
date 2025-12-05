import 'package:BookCLUB/models/livro_model.dart';
import 'package:BookCLUB/models/profile_model.dart';

class Resenha {
  final int? id;
  final Profile? usuario;
  final Livro livro;
  final int nota;
  final String comentario;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Resenha({
    this.id,
    this.usuario,
    required this.livro,
    required this.nota,
    required this.comentario,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Resenha.fromJson(Map<String, dynamic> json) {
    return Resenha(
      id: json['id'],
      usuario: json['usuario'] != null ? Profile.fromJson(json['usuario']) : null,
      livro: Livro.fromJson(json['livro']),
      nota: json['nota'],
      comentario: json['comentario'],
      criadoEm: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : null,
      atualizadoEm: json['atualizado_em'] != null ? DateTime.parse(json['atualizado_em']) : null,
    );
  }

  /// Método para enviar ao backend
  Map<String, dynamic> toJson() {
    return {
      "nota": nota,
      "comentario": comentario,
    };
  }
}
