import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Usuario usuario;

  const EditarUsuarioPage({required this.usuario, super.key});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  late TextEditingController nomeController;
  late TextEditingController bioController;
  final UsuarioService _service = UsuarioService();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.usuario.nome);
    bioController = TextEditingController(text: widget.usuario.bio);
  }

  Future<void> _salvar() async {
    final atualizado = Usuario(
      id: widget.usuario.id,
      nome: nomeController.text,
      usuario: widget.usuario.usuario,
      bio: bioController.text,
      fotoUrl: widget.usuario.fotoUrl,
    );

    await _service.atualizarUsuario(atualizado);
    Navigator.pop(context, atualizado); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B3EFF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child:
                  const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
