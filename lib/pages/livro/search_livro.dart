import 'package:flutter/material.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/models/livro_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/config/routes.dart';

class SearchLivro extends StatefulWidget {
  final Grupo grupo;

  const SearchLivro({
    super.key,
    required this.grupo,
  });

  @override
  State<SearchLivro> createState() => _SearchLivroState();
}

class _SearchLivroState extends State<SearchLivro> {
  final _repo = GrupoRepository();
  final TextEditingController _controller = TextEditingController();

  List<Livro> livros = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      buscar(_controller.text);
    });
  }

  void buscar(String texto) async {
    if (texto.isEmpty) {
      setState(() => livros = []);
      return;
    }

    setState(() => loading = true);

    final resultado = await _repo.searchLivro(texto);

    setState(() {
      livros = resultado;
      loading = false;
    });
  }

  Future<void> adicionarLivroAoGrupo(Livro livro) async {
    try {
      await _repo.criarTopicoComLivro(
        grupoId: widget.grupo.id!,
        livro: livro,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tópico criado com o livro \"${livro.titulo}\""),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao criar tópico: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Campo de busca
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Pesquisar livros...",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const Icon(Icons.search, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12)
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Resultados encontrados",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ---------------- LISTA DE RESULTADOS ----------------
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : livros.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum livro encontrado",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: livros.length,
                          itemBuilder: (context, index) {
                            final livro = livros[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    // ------- SEM IMAGEM -------

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              livro.titulo,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              livro.autor ??
                                                  "Autor desconhecido",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 18,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  livro.anoPublicacao ?? "",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // BOTÃO DE ADICIONAR
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: () {
                                          adicionarLivroAoGrupo(livro);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.purple,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
