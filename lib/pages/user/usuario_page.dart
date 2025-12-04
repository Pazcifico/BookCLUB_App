import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/models/resenha_model.dart';
import 'package:BookCLUB/config/api_config.dart';
import 'package:BookCLUB/repositories/userRepository.dart';

class UserPage extends StatefulWidget {
  static final String base = ApiConfig.baseUrl + "/media/";

  final Profile profile;

  const UserPage({super.key, required this.profile});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserRepository _userRepository = UserRepository();

  File? _fotoPerfil;
  List<Resenha> _resenhas = [];
  bool _isLoading = true;
  bool _seguindo = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  // -------------------------------------------------------
  // Inicializa a página
  // -------------------------------------------------------
  Future<void> _initAll() async {
    setState(() => _isLoading = true);

    try {
      final res = await _userRepository.getResenhas(widget.profile.userId!);
      setState(() => _resenhas = res);

      final isFollowing = await _userRepository.checarSegue(widget.profile.userId!);
      setState(() => _seguindo = isFollowing);
    } catch (e) {
      debugPrint("Erro ao inicializar UserPage: $e");
      setState(() => _seguindo = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // -------------------------------------------------------
  // Escolher foto local
  // -------------------------------------------------------
  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _fotoPerfil = File(img.path));
  }

  // -------------------------------------------------------
  // Construção de imagem
  // -------------------------------------------------------
  ImageProvider _buildFotoPerfil(Profile profile) {
    if (_fotoPerfil != null) return FileImage(_fotoPerfil!);
    final pic = profile.profilePicture;
    if (pic != null && pic.isNotEmpty && pic != "null") {
      return NetworkImage("${UserPage.base}$pic");
    }
    return const AssetImage("assets/img/placeholder.jpg");
  }

  ImageProvider _img(dynamic file, String? remotePath) {
    if (file != null) return FileImage(file);
    if (remotePath != null && remotePath.isNotEmpty && remotePath != "null") {
      return NetworkImage("${UserPage.base}$remotePath");
    }
    return const AssetImage("assets/img/placeholder.jpg");
  }

  // -------------------------------------------------------
  // Toggle follow/unfollow
  // -------------------------------------------------------
  Future<void> _toggleFollow() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    try {
      final success = await _userRepository.seguir(widget.profile.userId!);

      if (!mounted) return;

      if (success) {
        final nowFollowing = await _userRepository.checarSegue(widget.profile.userId!);
        setState(() {
          _seguindo = nowFollowing;
          final current = widget.profile.followersCount ?? 0;
          widget.profile.followersCount =
              nowFollowing ? current + 1 : (current - 1).clamp(0, 1 << 30);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao alternar seguir.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao togglear follow: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro de conexão.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  // -------------------------------------------------------
  // Build principal
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(profile),
                  const SizedBox(height: 25),
                  _buildUserInfo(profile),
                  const SizedBox(height: 20),
                  _buildStats(profile),
                  const SizedBox(height: 25),
                  _buildButtons(),
                  const SizedBox(height: 25),
                  _buildResenhasSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // -------------------------------------------------------
  // Header com banner e foto
  // -------------------------------------------------------
  Widget _buildHeader(Profile profile) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffe5e5e5),
            image: (profile.thumbnail != null &&
                    profile.thumbnail!.isNotEmpty &&
                    profile.thumbnail != "null")
                ? DecorationImage(
                    image: NetworkImage("${UserPage.base}${profile.thumbnail}"),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        Positioned(
          left: 20,
          top: 40,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.6),
              child: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _buildFotoPerfil(profile),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // User info
  // -------------------------------------------------------
  Widget _buildUserInfo(Profile profile) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Text(
          profile.name ?? "",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "@${profile.username}",
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Text(
          profile.bio ?? "",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // Stats
  // -------------------------------------------------------
  Widget _buildStats(Profile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statBox("${profile.livrosCount}", "livros lidos"),
        _statBox("${profile.followersCount}", "seguidores"),
        _statBox("${profile.followingCount}", "seguindo"),
      ],
    );
  }

  Widget _statBox(String num, String label) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xffe8e8e8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(num, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Follow buttons atualizados
  // -------------------------------------------------------
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 50),
          child: _seguindo ? _followingButton() : _followButton(),
        ),
      ],
    );
  }

  Widget _followButton() {
    return GestureDetector(
      onTap: _isToggling ? null : _toggleFollow,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isToggling
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Center(
                child: Text(
                  "seguir",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Widget _followingButton() {
    return GestureDetector(
      onTap: _isToggling ? null : _toggleFollow,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          border: Border.all(color: Colors.purple),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isToggling
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
              )
            : const Center(
                child: Text(
                  "seguindo",
                  style: TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  // -------------------------------------------------------
  // Resenhas
  // -------------------------------------------------------
  Widget _buildResenhasSection() {
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
        const SizedBox(height: 15),
        if (_resenhas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Nenhuma resenha ainda...",
              style: TextStyle(fontSize: 17),
            ),
          )
        else
          ..._resenhas.map((r) => _resenhaCard(r)),
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
            backgroundImage: _img(null, widget.profile.profilePicture),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("@${widget.profile.username}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  r.comentario ?? "",
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 12),
                if (livro != null) _bookCard(r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookCard(Resenha r) {
    final livro = r.livro!;

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
                Text(
                  livro.titulo ?? "",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  livro.autor ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    r.nota ?? 0,
                    (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
