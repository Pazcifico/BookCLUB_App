import 'package:flutter/material.dart';
import 'package:BookCLUB/config/routes.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/config/api_config.dart';

class SearchPage extends StatefulWidget {
  static final String base = ApiConfig.baseUrl + "/media/";
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedTab = "grupo"; // "grupo" ou "usuario"
  final TextEditingController _searchController = TextEditingController();
  final GrupoRepository _repository = GrupoRepository();

  List<dynamic> _results = [];
  bool _isLoading = false;

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    final tipo = selectedTab; 
    final data = await _repository.search(query: value, tipo: tipo);

    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildSearchBar(),
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 20),
              Expanded(child: _buildResultsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
                hintText: "Buscar",
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
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _tabButton(
            title: "Grupos",
            active: selectedTab == "grupo",
            onTap: () => setState(() {
              selectedTab = "grupo";
              _onSearchChanged(_searchController.text);
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tabButton(
            title: "Usuários",
            active: selectedTab == "usuario",
            onTap: () => setState(() {
              selectedTab = "usuario";
              _onSearchChanged(_searchController.text);
            }),
          ),
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.amber.shade400 : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: active ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return const Center(child: Text("Nenhum resultado encontrado"));
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _results[index];

        String name;
        String? imageUrl;

        if (selectedTab == "grupo" && item is Grupo) {
          name = item.nome ?? "Sem nome";
          imageUrl = item.imagem;
        } else if (selectedTab == "usuario" && item is Profile) {
          name = (item.name != null && item.name!.isNotEmpty)
              ? item.name!
              : item.username ?? "Sem nome";
          imageUrl = item.profilePicture;
        } else {
          name = "Sem nome";
          imageUrl = null;
        }

        ImageProvider imageProvider;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (imageUrl.startsWith("http")) {
            imageProvider = NetworkImage(imageUrl);
          } else {
            imageProvider = NetworkImage('${SearchPage.base}$imageUrl');
          }
        } else {
          imageProvider = const AssetImage("assets/img/placeholder.jpg");
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: (selectedTab == "grupo" && item is Grupo)
                ? () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.group,
                      arguments: item,
                    );
                  }
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.user,
                      arguments: item,
                    );
                  },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(radius: 28, backgroundImage: imageProvider),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
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
    );
  }
}
