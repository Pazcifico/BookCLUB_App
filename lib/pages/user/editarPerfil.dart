import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/config/api_config.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/config/routes.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;
  static final String base = ApiConfig.baseUrl + "/media/";

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _bioController;

  XFile? _profilePicture;
  XFile? _thumbnail;
  Uint8List? _profileBytes;
  Uint8List? _thumbBytes;
  bool _isLoading = false;

  final UserRepository _repository = UserRepository();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio ?? "");
  }

  Future<void> _pickImage(bool isThumbnail) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isThumbnail) {
          _thumbnail = pickedFile;
          _thumbBytes = bytes;
        } else {
          _profilePicture = pickedFile;
          _profileBytes = bytes;
        }
      });
    }
  }

  // Retorna ImageProvider da profile picture
  ImageProvider<Object> _buildProfileImage() {
    if (_profileBytes != null) return MemoryImage(_profileBytes!);
    if (widget.profile.profilePicture != null &&
        widget.profile.profilePicture!.isNotEmpty) {
      return NetworkImage(
          "${EditProfilePage.base}${widget.profile.profilePicture!}");
    }
    return const AssetImage("assets/img/placeholder.jpg");
  }

  // Retorna ImageProvider da thumbnail
  ImageProvider<Object> _buildThumbnailImage() {
    if (_thumbBytes != null) return MemoryImage(_thumbBytes!);
    if (widget.profile.thumbnail != null && widget.profile.thumbnail!.isNotEmpty) {
      return NetworkImage("${EditProfilePage.base}${widget.profile.thumbnail!}");
    }
    return const AssetImage("assets/img/default_thumb.png");
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProfile = Profile(
        id: widget.profile.id,
        userId: widget.profile.userId,
        username: widget.profile.username,
        name: _nomeController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        profilePicture: widget.profile.profilePicture,
        thumbnail: widget.profile.thumbnail,
      );

      bool success = await _repository.editarPerfil(
        profile: updatedProfile,
        profilePicture: _profilePicture,
        thumbnail: _thumbnail,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                success ? "Perfil atualizado!" : "Erro ao atualizar perfil.")),
      );

      if (success) Navigator.pushNamed(context, AppRoutes.perfil);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao editar perfil: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // 🔹 Imagem de fundo (thumbnail)
      GestureDetector(
        onTap: () => _pickImage(true),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _buildThumbnailImage(),
              fit: BoxFit.cover,
            ),
            color: Colors.grey.shade300,
          ),
        ),
      ),

      // 🔹 Botão de Voltar (sem AppBar)
      Positioned(
        top: 20,
        left: 12,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.amber,
              size: 24,
            ),
          ),
        ),
      ),

      // 🔹 Avatar (profile picture)
      Positioned(
        bottom: -40,
        left: MediaQuery.of(context).size.width / 2 - 70,
        child: GestureDetector(
          onTap: () => _pickImage(false),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _buildProfileImage(),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: "Nome",
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? "Digite o nome" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: "Bio",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Salvar mudanças",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
