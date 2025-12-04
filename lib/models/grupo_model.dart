class Grupo {
  final int? id;
  final String? nome;
  final String? descricao;
  final bool? privado;
  final String? imagem;
  final List<int>? membros; // IDs dos membros

  Grupo({
    this.id,
    this.nome,
    this.descricao,
    this.privado,
    this.imagem,
    this.membros,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] != null ? json['id'] as int : null,
      nome: json['nome']?.toString(),
      descricao: json['descricao']?.toString(),
      privado: json['privado'] != null ? json['privado'] as bool : null,
      imagem: json['imagem']?.toString(),
      membros: json['membros'] != null
          ? List<int>.from(json['membros'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'privado': privado,
      'imagem': imagem,
      'membros': membros,
    };
  }
}
