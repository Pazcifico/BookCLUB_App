import 'package:BookCLUB/config/api_routes.dart';
import 'package:flutter/material.dart';
import 'package:BookCLUB/models/resenha_model.dart';
import 'package:BookCLUB/models/livro_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/config/routes.dart';

class ResenhaPage extends StatefulWidget {
  final int livro; // já é obrigatório

  const ResenhaPage({
    super.key,
    required this.livro,
  });

  @override
  State<ResenhaPage> createState() => _ResenhaPageState();
}

class _ResenhaPageState extends State<ResenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();

  final UserRepository _repository = UserRepository(); // <-- IMPORTANTE!

  int _nota = 3;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final livro = Livro(id: widget.livro);

      final resenha = Resenha(
        id: null,
        usuario: null, // será definido no backend pelo token
        livro: livro,
        nota: _nota,
        comentario: _comentarioController.text,
      );

      final sucesso = await _repository.createResenha(resenha);

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resenha enviada com sucesso!")),
        );

        Navigator.pushNamed(context, AppRoutes.perfil);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao enviar resenha.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar resenha: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(5, (index) {
        final number = index + 1;
        return IconButton(
          icon: Icon(
            number <= _nota ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            setState(() => _nota = number);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nota",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              _buildStars(),

              const SizedBox(height: 20),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  labelText: "Comentário",
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (v) =>
                    v == null || v.isEmpty ? "Escreva um comentário" : null,
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          "Enviar Resenha",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
