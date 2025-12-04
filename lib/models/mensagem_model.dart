import 'package:BookCLUB/models/profile_model.dart';

class Mensagem {
  final int id;
  final int topicoId;
  final Profile? usuario;
  final String conteudo;
  final String? imagem;
  final int? capitulo;
  final bool isSpoiler;
  final DateTime criadoEm;
  final List<int> lidosPor;

  Mensagem({
    required this.id,
    required this.topicoId,
    required this.usuario,
    required this.conteudo,
    this.imagem,
    this.capitulo,
    required this.isSpoiler,
    required this.criadoEm,
    required this.lidosPor,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] ?? 0,
      topicoId: json['topico'] ?? 0,

      /// usuário pode vir NULL no Django
      usuario: json['usuario_detail'] != null
          ? Profile.fromJson(json['usuario_detail'])
          : null,

      conteudo: json['conteudo'] ?? "",
      imagem: json['imagem'],
      capitulo: json['capitulo'],
      isSpoiler: json['is_spoiler'] ?? false,
      criadoEm: DateTime.parse(json['criado_em']),
      
      /// lidos_por: lista de ids
      lidosPor: json['lidos_por'] != null
          ? List<int>.from(json['lidos_por'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topico': topicoId,
      'usuario': usuario?.id,
      'conteudo': conteudo,
      'imagem': imagem,
      'capitulo': capitulo,
      'is_spoiler': isSpoiler,
      'criado_em': criadoEm.toIso8601String(),
      'lidos_por': lidosPor,
    };
  }
}
