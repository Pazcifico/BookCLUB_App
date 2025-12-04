class Livro {
  final int id;
  final String titulo;
  final String? autor;
  final String? descricao;
  final String? capa;
  final String? anoPublicacao;
  final String identificadorApi;

  Livro({
    required this.id,
    required this.titulo,
    this.autor,
    this.descricao,
    this.capa,
    this.anoPublicacao,
    required this.identificadorApi,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'],
      titulo: json['titulo'],
      autor: json['autor'],
      descricao: json['descricao'],
      capa: json['capa'],
      anoPublicacao: json['ano_publicacao'],
      identificadorApi: json['identificador_api'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "titulo": titulo,
      "autor": autor,
      "descricao": descricao,
      "capa": capa,
      "ano_publicacao": anoPublicacao,
      "identificador_api": identificadorApi,
    };
  }
}
