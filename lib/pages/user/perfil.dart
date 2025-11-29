import 'dart:io';
import 'package:BookCLUB/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/config/routes.dart';

class ProfilePage extends StatefulWidget {
  static final String base = ApiConfig.baseUrl + "/media/";
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

      // Se quiser salvar no backend: await _userRepository.updateProfile(profile!)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
  currentIndex: 2,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.purple,
  unselectedItemColor: Colors.grey,
  showSelectedLabels: false,
  showUnselectedLabels: false,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 32),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search, size: 32),
      label: "Buscar",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 32),
      label: "Perfil",
    ),
  ],
  onTap: (index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.search);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.perfil);
        break;
    }
  },
),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 15),
            _buildButtons(),
            const SizedBox(height: 25),
            _buildFavoritos(),
            const SizedBox(height: 25),
            _buildResenhas(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // HEADER --------------------------------------------------------------------------------------

  Widget _buildHeader() {
  return Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      // Thumbnail de fundo
      Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffe5e5e5), // fallback
          image: profile!.thumbnail != null
              ? DecorationImage(
                  image: NetworkImage('${ProfilePage.base}${profile!.thumbnail!}'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),

      // Back button
      Positioned(
        left: 20,
        top: 40,
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.6),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),

      // Avatar
      Positioned(
        bottom: -40,
        child: GestureDetector(
          onTap: _escolherFoto,
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _fotoPerfil != null
                ? FileImage(_fotoPerfil!)
                : profile!.profilePicture != null
                    ? NetworkImage('${ProfilePage.base}${profile!.profilePicture!}')
                    : null as ImageProvider?,
            child: (_fotoPerfil == null && profile!.profilePicture == null)
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
        ),
      ),
    ],
  );
}


  // USER INFO ------------------------------------------------------------------------------------

  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 45),
        Text(
          profile!.name ?? "",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "@${profile!.username}",
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Text(
          profile!.bio ?? "",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // STATS ----------------------------------------------------------------------------------------

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatBox("0", "livros lidos"),
        _buildStatBox("0", "seguidores"),
        _buildStatBox("0", "seguindo"),
      ],
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xffe8e8e8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // BUTTONS --------------------------------------------------------------------------------------

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _mainButton("editar perfil", _editarPerfil),
      ],
    );
  }

  Widget _mainButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 212,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // FAVORITOS ------------------------------------------------------------------------------------

  Widget _buildFavoritos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Favoritos",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _favBook("assets/img/placeholder.jpg"),
              _favBook("assets/img/placeholder.jpg"),
              _favBook("assets/img/placeholder.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _favBook(String path) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // RESENHAS -------------------------------------------------------------------------------------

  Widget _buildResenhas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Resenhas",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: profile!.profilePicture != null
                    ? NetworkImage('${ProfilePage.base}${profile!.profilePicture!}')
                    : const AssetImage("assets/img/placeholder.jpg")
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Text(
                "@${profile!.username}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Nenhuma resenha ainda...",
            style: TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
