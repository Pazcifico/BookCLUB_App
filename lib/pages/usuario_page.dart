import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({Key? key}) : super(key: key);

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final UsuarioService _service = UsuarioService();
  Usuario? usuario;
  File? _fotoPerfil;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    try {
      final user = await _service.getUsuario(1); // 👈 ID fixo por enquanto
      setState(() => usuario = user);
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  Future<void> _escolherFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() => _fotoPerfil = File(imagem.path));
    }
  }

  Future<void> _editarPerfil() async {
    if (usuario == null) return;

    final resultado = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        String nome = usuario!.nome;
        String bio = usuario!.bio;

        return AlertDialog(
          title: const Text('Editar perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: nome),
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (v) => nome = v,
              ),
              TextField(
                controller: TextEditingController(text: bio),
                decoration: const InputDecoration(labelText: 'Bio'),
                onChanged: (v) => bio = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, {'nome': nome, 'bio': bio}),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado != null) {
      setState(() {
        usuario!.nome = resultado['nome']!;
        usuario!.bio = resultado['bio']!;
      });

      await _service.atualizarUsuario(usuario!); // 👈 Envia pra API
    }
  }

  @override
  Widget build(BuildContext context) {
    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _escolherFoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF7B3EFF),
                  backgroundImage: _fotoPerfil != null
                      ? FileImage(_fotoPerfil!)
                      : (usuario!.fotoUrl != null
                          ? NetworkImage(usuario!.fotoUrl!)
                          : null) as ImageProvider?,
                  child: (_fotoPerfil == null && usuario!.fotoUrl == null)
                      ? const Icon(Icons.camera_alt,
                          color: Colors.white, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              Text(usuario!.nome,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text(usuario!.usuario,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              Text(usuario!.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarPerfil,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3EFF)),
                child: const Text('Editar perfil',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
