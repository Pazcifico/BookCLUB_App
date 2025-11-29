import 'package:flutter/material.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/config/api_config.dart';
import 'package:BookCLUB/models/topico_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';

class GroupPage extends StatelessWidget {
  final Grupo grupo;
  static final String base = ApiConfig.baseUrl + "/media/";

  const GroupPage({super.key, required this.grupo});

  @override
  Widget build(BuildContext context) {
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
              backgroundImage: grupo.imagem != null && grupo.imagem!.isNotEmpty
                  ? NetworkImage(GroupPage.base + grupo.imagem!)
                  : const AssetImage('assets/img/placeholder.jpg') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              grupo.nome ?? 'Sem nome', // fallback caso seja null
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Colors.amber),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.amber),
          SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Topico>>(
        future: GrupoRepository().getTopicosGrupo(grupo.id ?? 0), // fallback seguro para id
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Erro
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar tópicos"));
          }

          // Sem tópicos
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum tópico criado ainda."));
          }

          final topicos = snapshot.data!;

          return ListView.builder(
            itemCount: topicos.length,
            itemBuilder: (context, index) {
              final t = topicos[index];

              return ChatCategoryTile(
                title: t.nome ?? 'Sem título', // fallback
                user: t.ultimaMensagemUsuario ?? "",
                message: t.ultimaMensagemTexto ?? "",
              );
            },
          );
        },
      ),
    );
  }
}

class ChatCategoryTile extends StatelessWidget {
  final String title;
  final String user;
  final String message;

  const ChatCategoryTile({
    super.key,
    required this.title,
    required this.user,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasMessage = user.isNotEmpty && message.isNotEmpty;

    return Column(
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

              // 👉 Só mostra se houver última mensagem
              if (hasMessage) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$user: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: message),
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
    );
  }
}
