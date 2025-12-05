class Livro {
  final int? id; // <-- pode ser null, porque vem do Google sem id local
  final String? titulo;
  final String? autor;
  final String? descricao;
  final String? capa;
  final String? anoPublicacao;
  final String? identificadorApi;

  Livro({
    this.id,
    this.titulo,
    this.autor,
    this.descricao,
    this.capa,
    this.anoPublicacao,
    this.identificadorApi,
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

  factory Livro.fromGoogleJson(Map<String, dynamic> item) {
    final volume = item["volumeInfo"] ?? {};

    return Livro(
      id: null, // Google não possui ID interno do seu app
      titulo: volume["title"] ?? "Sem título",
      autor: volume["authors"] != null
          ? (volume["authors"] as List).join(", ")
          : null,
      descricao: volume["description"],
      capa: volume["imageLinks"]?["smallThumbnail"],

      anoPublicacao: volume["publishedDate"],
      identificadorApi: item["id"], // ID do Google Books
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
