import 'dart:io';
import 'package:BookCLUB/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/models/resenha_model.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/config/routes.dart';
import 'package:BookCLUB/pages/user/editarPerfil.dart';

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

  List<Resenha> _resenhas = [];

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    setState(() => _isLoading = true);

    try {
      final perfil = await _userRepository.getProfile();

      if (perfil?.userId != null) {
        final resenhas = await _userRepository.getResenhas(perfil!.userId!);
        setState(() => _resenhas = resenhas);
      }

      setState(() => profile = perfil);
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _fotoPerfil = File(imagem.path);
      });
    }
  }

  List<PopupMenuEntry<String>> _menuOpcoes(BuildContext context) {
  return [
    const PopupMenuItem(
      value: "sair",
      child: Text("Logout"),
    ),
  ];
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
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 20),
            _buildButtons(),
            const SizedBox(height: 20),
            _buildResenhas(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  //       BOTTOM NAV
  // -----------------------------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 32), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 32), label: "Buscar"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 32), label: "Perfil"),
      ],
      onTap: (i) {
        switch (i) {
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
    );
  }

  // -----------------------------
  //           HEADER
  // -----------------------------
// -----------------------------
//           HEADER
// -----------------------------
Widget _buildHeader() {
  return Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      // BANNER
      Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          image: (profile?.thumbnail?.isNotEmpty ?? false)
              ? DecorationImage(
                  image: NetworkImage(
                    "${ProfilePage.base}${profile!.thumbnail}",
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),

      // ÍCONE DO MENU
      Positioned(
        right: 20,
        top: 40,
        child: PopupMenuButton<String>(
          icon: Icon(Icons.menu, size: 30, color: Colors.amber.shade700),
          itemBuilder: _menuOpcoes,
          onSelected: (value) {
            switch (value) {
  
              case "sair":
                _userRepository.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
                break;
            }
          },
        ),
      ),

      // FOTO DE PERFIL (SEM GESTURE E SEM ÍCONE DE CÂMERA)
      Positioned(
        bottom: -40,
        child: CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: (() {
            if (_fotoPerfil != null) {
              return FileImage(_fotoPerfil!) as ImageProvider;
            }
            if (profile?.profilePicture != null &&
                profile!.profilePicture!.isNotEmpty) {
              return NetworkImage(
                "${ProfilePage.base}${profile!.profilePicture}",
              );
            }
            return const AssetImage("assets/img/placeholder.jpg");
          })(),
        ),
      ),
    ],
  );
}


  // -----------------------------
  //        USER INFO
  // -----------------------------
  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Text(
          profile?.name?.isNotEmpty == true
              ? profile!.name!
              : profile!.username,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "@${profile!.username}",
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Text(
          profile?.bio ?? "",
          style: const TextStyle(fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -----------------------------
  //           STATS
  // -----------------------------
  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatBox("${profile?.livrosCount ?? 0}", "livros lidos"),
        _buildStatBox("${profile?.followersCount ?? 0}", "seguidores"),
        _buildStatBox("${profile?.followingCount ?? 0}", "seguindo"),
      ],
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xffe8e8e8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(number,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  // -----------------------------
  //          BOTÕES
  // -----------------------------
  Widget _buildButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 50), // margem do botão
        child: _mainButton("editar perfil", () {
          if (profile != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(profile: profile!),
              ),
            ).then((_) => _carregarUsuario());
          }
        }),
      ),
    ],
  );
}


  Widget _mainButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // -----------------------------
  //          RESENHAS
  // -----------------------------
  Widget _buildResenhas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Resenhas",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        if (_resenhas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Nenhuma resenha publicada ainda."),
          )
        else
          ..._resenhas.map((r) => _resenhaCard(r)).toList(),
      ],
    );
  }

  Widget _resenhaCard(Resenha r) {
    final livro = r.livro;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: (profile?.profilePicture?.isNotEmpty ?? false)
                ? NetworkImage("${ProfilePage.base}${profile!.profilePicture}")
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("@${profile!.username}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(r.comentario ?? "",
                    style: const TextStyle(fontSize: 16, height: 1.4)),
                const SizedBox(height: 12),
                if (livro != null) _bookReviewCard(r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookReviewCard(Resenha r) {
    final livro = r.livro;
    if (livro == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff0f0f0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(livro.titulo ?? "",
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(livro.autor ?? "",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                      r.nota ?? 0,
                      (_) => const Icon(Icons.star,
                          color: Colors.amber, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
