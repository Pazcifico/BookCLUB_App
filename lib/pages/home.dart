import 'package:flutter/material.dart';
import 'package:BookCLUB/config/routes.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/config/api_config.dart';

class HomePage extends StatefulWidget {
  static final String base = ApiConfig.baseUrl + "/media/";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GrupoRepository _grupoRepository = GrupoRepository();
  List<Grupo> _grupos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
  }

  Future<void> _carregarGrupos() async {
    setState(() => _isLoading = true);
    final grupos = await _grupoRepository.getGruposUsuario();
    setState(() {
      _grupos = grupos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 20),
            const Icon(Icons.menu_book_rounded, color: Colors.purple, size: 30),
            const SizedBox(width: 8),
            const Text(
              "BookCLUB",
              style: TextStyle(
                fontSize: 22,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.purple,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.searchMembros);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _grupos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final grupo = _grupos[index];

                // Garante fallback seguro para imagem
                ImageProvider imageProvider = (grupo.imagem != null && grupo.imagem!.isNotEmpty)
                    ? NetworkImage('${HomePage.base}${grupo.imagem!}')
                    : const AssetImage("assets/img/placeholder.jpg") as ImageProvider;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: InkWell(
                    onTap: () {
                      // Passa o grupo de forma segura
                      Navigator.pushNamed(
                        context,
                        AppRoutes.group,
                        arguments: grupo,
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: imageProvider,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            grupo.nome ?? '', // fallback para string vazia se null
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
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
    );
  }
}
