class Topico {
  final int id;
  final String nome;
  final int? livro;
  final int? criadoPor;
  final int qtdMensagens;

  final String? ultimaMensagemUsuario;
  final String? ultimaMensagemTexto;
  final DateTime? ultimaMensagemData;

  Topico({
    required this.id,
    required this.nome,
    required this.livro,
    required this.criadoPor,
    required this.qtdMensagens,
    this.ultimaMensagemUsuario,
    this.ultimaMensagemTexto,
    this.ultimaMensagemData,
  });

  factory Topico.fromJson(Map<String, dynamic> json) {
    final ultima = json["ultima_mensagem"];

    return Topico(
      id: json["id"],
      nome: json["nome"],
      livro: json["livro"],
      criadoPor: json["criado_por"],
      qtdMensagens: json["qtd_mensagens"],

      ultimaMensagemUsuario: ultima != null ? ultima["usuario"] : null,
      ultimaMensagemTexto: ultima != null ? ultima["conteudo"] : null,
      ultimaMensagemData: ultima != null && ultima["criado_em"] != null
          ? DateTime.parse(ultima["criado_em"])
          : null,
    );
  }
}
