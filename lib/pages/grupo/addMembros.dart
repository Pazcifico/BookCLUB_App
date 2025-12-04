import 'package:flutter/material.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/config/api_config.dart';

class AddMembros extends StatefulWidget {
  final int grupoId; // ⬅️ necessário para enviar ao backend

  static final String base = ApiConfig.baseUrl + "/media/";

  const AddMembros({super.key, required this.grupoId});

  @override
  State<AddMembros> createState() => _AddMembrosState();
}

class _AddMembrosState extends State<AddMembros> {
  final TextEditingController _searchController = TextEditingController();
  final GrupoRepository _repository = GrupoRepository();

  List<Profile> _results = [];
  List<Profile> _allMembros = [];
  bool _isLoading = false;

  List<int> membros = []; // IDs dos selecionados

  @override
  void initState() {
    super.initState();
    _loadMembros();
  }

  Future<void> _loadMembros() async {
    setState(() => _isLoading = true);
    final data = await _repository.selecionarMembros();
    setState(() {
      _allMembros = data.cast<Profile>();
      _results = _allMembros;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      setState(() => _results = _allMembros);
      return;
    }

    final filtered = _allMembros.where((user) {
      final name = user.name ?? user.username;
      return name.toLowerCase().contains(value.toLowerCase());
    }).toList();

    setState(() => _results = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackAndSearchBar(),
              const SizedBox(height: 20),
              Expanded(child: _buildResultsList()),
            ],
          ),
        ),
      ),

      // ⬇️ Aqui mudou: agora envia para o GrupoRepository.addMembros
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.arrow_forward, color: Colors.white),
        onPressed: () async {
          final ok = await _repository.addMembros(widget.grupoId, membros);

          if (ok) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Erro ao adicionar membros"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBackAndSearchBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Buscar membros",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.amber.shade600),
                  onPressed: () => _onSearchChanged(_searchController.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_results.isEmpty) return const Center(child: Text("Nenhum membro encontrado"));

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final Profile user = _results[index];
        final String name = (user.name != null && user.name!.isNotEmpty)
            ? user.name!
            : user.username;

        final String? imageUrl = user.profilePicture;

        late final ImageProvider<Object> imageProvider;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final url = imageUrl.startsWith("http")
              ? imageUrl
              : '${AddMembros.base}$imageUrl';
          imageProvider = NetworkImage(url);
        } else {
          imageProvider = const AssetImage("assets/img/placeholder.jpg");
        }

        final bool isSelected = membros.contains(user.userId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 28, backgroundImage: imageProvider),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$name (${user.userId})",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(isSelected ? Icons.check : Icons.add, color: Colors.purple),
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      membros.remove(user.userId);
                    } else {
                      membros.add(user.userId);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
