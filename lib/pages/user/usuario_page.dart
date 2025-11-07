import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({Key? key}) : super(key: key);

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final UserRepository _userRepository = UserRepository();
  Profile? profile;
  File? _fotoPerfil;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    setState(() => _isLoading = true);
    try {
      final perfil = await _userRepository.getProfile();
      setState(() => profile = perfil);
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() => _fotoPerfil = File(imagem.path));
    }
  }

  Future<void> _editarPerfil() async {
    if (profile == null) return;

    final resultado = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        String nome = profile!.name ?? '';
        String bio = profile!.bio ?? '';

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
        profile!.name = resultado['nome'];
        profile!.bio = resultado['bio'];
      });

      try {
        //await _userRepository.updateProfile(profile!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        debugPrint('Erro ao atualizar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Não foi possível carregar o usuário')),
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
                      : (profile!.profilePicture != null
                          ? NetworkImage(profile!.profilePicture!)
                          : null) as ImageProvider?,
                  child: (_fotoPerfil == null &&
                          profile!.profilePicture == null)
                      ? const Icon(Icons.camera_alt,
                          color: Colors.white, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                profile!.name ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                profile!.bio ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B3EFF),
                ),
                child: const Text(
                  'Editar perfil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
