import 'package:flutter/material.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/config/api_config.dart';
import 'package:BookCLUB/models/topico_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/pages/grupo/topico.dart';
import "package:BookCLUB/config/routes.dart";
import 'package:BookCLUB/pages/grupo/addMembros.dart';
import 'package:BookCLUB/pages/grupo/editGrupo.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/models/profile_model.dart';

class GroupPage extends StatefulWidget {
  final Grupo grupo;
  static final String base = ApiConfig.baseUrl + "/media/";

  const GroupPage({super.key, required this.grupo});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final UserRepository _userRepository = UserRepository();
  int? currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final profile = await _userRepository.getProfile();
      setState(() {
        currentUserId = profile?.userId;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao pegar usuário: $e");
      setState(() => _isLoading = false);
    }
  }

  List<PopupMenuEntry<String>> _menuOpcoes(BuildContext context) {
    if (currentUserId == null) return [];

    final isMember = widget.grupo.membros?.contains(currentUserId) ?? false;

    if (!isMember) {
      return [
        const PopupMenuItem(
          value: "entrar",
          child: Text("Entrar no Grupo"),
        ),
      ];
    } else {
      return [
        const PopupMenuItem(
          value: "adicionar",
          child: Text("Adicionar Membro"),
        ),
        const PopupMenuItem(
          value: "editar",
          child: Text("Configurações do Grupo"),
        ),
        const PopupMenuItem(
          value: "criar",
          child: Text("Criar Tópico"),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: "sair",
          child: Text("Sair do Grupo"),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.grupo.imagem != null &&
                      widget.grupo.imagem!.isNotEmpty
                  ? NetworkImage(GroupPage.base + widget.grupo.imagem!)
                  : const AssetImage('assets/img/placeholder.jpg')
                      as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              widget.grupo.nome ?? 'Sem nome',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.amber),
            itemBuilder: (context) => _menuOpcoes(context),
            onSelected: (value) async {
              switch (value) {
                case "entrar":
                  final sucesso =
                      await GrupoRepository().entrarNoGrupo(widget.grupo.id!);
                  if (sucesso) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Você entrou no grupo")),
                    );
                    setState(() {
                      widget.grupo.membros?.add(currentUserId!);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro ao entrar no grupo")),
                    );
                  }
                  break;

                case "adicionar":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMembros(grupoId: widget.grupo.id!),
                    ),
                  );
                  break;

                case "editar":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditGrupoPage(grupo: widget.grupo),
                    ),
                  );
                  break;

                case "criar":
                  print("Criar tópico");
                  break;

                case "sair":
                  final sucesso =
                      await GrupoRepository().sairDoGrupo(widget.grupo.id!);
                  if (sucesso) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Você saiu do grupo")),
                    );
                    setState(() {
                      widget.grupo.membros?.remove(currentUserId);
                    });
                    Navigator.pushNamed(context, AppRoutes.home);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro ao sair do grupo")),
                    );
                  }
                  break;
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Topico>>(
        future: GrupoRepository().getTopicosGrupo(widget.grupo.id ?? 0),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar tópicos"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum tópico criado ainda."));
          }

          final topicos = snapshot.data!;

          return ListView.builder(
            itemCount: topicos.length,
            itemBuilder: (context, index) {
              return ChatCategoryTile(topico: topicos[index]);
            },
          );
        },
      ),
    );
  }
}

// -------------------------
// TILE DO TÓPICO
// -------------------------
class ChatCategoryTile extends StatelessWidget {
  final Topico topico;

  const ChatCategoryTile({
    super.key,
    required this.topico,
  });

  @override
  Widget build(BuildContext context) {
    final String title = topico.nome ?? "Sem título";
    final String? user = topico.ultimaMensagemUsuario;
    final String? msg = topico.ultimaMensagemTexto;

    final bool hasMessage =
        user != null && msg != null && user.isNotEmpty && msg.isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TopicPage(topico: topico),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "# $title",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasMessage) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "$user: ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: msg),
                      ],
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
