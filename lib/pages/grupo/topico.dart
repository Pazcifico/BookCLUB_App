import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:BookCLUB/pages/livro/resenha_page.dart';
import 'package:BookCLUB/models/topico_model.dart';
import 'package:BookCLUB/models/mensagem_model.dart';
import 'package:BookCLUB/models/profile_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/services/ChatWebSocketService.dart';
import 'package:BookCLUB/config/api_config.dart';

class TopicPage extends StatefulWidget {
  final Topico topico;
  static final String base = ApiConfig.baseUrl + "/media/";

  const TopicPage({super.key, required this.topico});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Mensagem> mensagens = [];
  late ChatWebSocketService socket;
  bool carregando = true;
  Profile? meuProfile;

  bool spoilerMode = false;
  int? spoilerCapitulo;
  XFile? imagemSelecionada;
  bool socketConnected = false;

  late final Stream<dynamic> _wsStream;
  late final StreamSubscription _wsSubscription;

  @override
void initState() {
  super.initState(); // não esqueça de chamar super.initState()
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    carregarPerfil();
    carregarInicial();
    iniciarWebSocket();
  });
}


  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    try { socket.disconnect(); } catch (_) {}
    try { _wsSubscription.cancel(); } catch (_) {}
    super.dispose();
  }

  Future<void> carregarPerfil() async {
    final repo = UserRepository();
    final profile = await repo.getProfile();
    if (profile != null) {
      setState(() => meuProfile = profile);
    } else {
      debugPrint("⚠️ Não foi possível recuperar o perfil do usuário logado.");
    }
  }

  Future<void> carregarInicial() async {
    try {
      final repo = GrupoRepository();
      final lista = await repo.getMensagens(widget.topico.id);

      setState(() {
        mensagens = lista;
        carregando = false;
      });

      Future.delayed(const Duration(milliseconds: 120), () {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      debugPrint("Erro ao carregar mensagens iniciais: $e");
      setState(() {
        mensagens = [];
        carregando = false;
      });
    }
  }

  void iniciarWebSocket() {
    try {
      socket = ChatWebSocketService();
      socket.connect(widget.topico.id);
      socketConnected = true;

      _wsStream = socket.messagesStream;
      _wsSubscription = _wsStream.listen((data) {
        try {
          final Map<String, dynamic> jsonData =
              data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

          if (jsonData['type'] != 'chat_message') return;

          final userId = int.tryParse(jsonData['user_id'].toString()) ?? 0;
          final criadoEm = DateTime.tryParse(jsonData['timestamp'] ?? '') ?? DateTime.now();

          final msgJson = {
            'id': jsonData['id'] ?? 0,
            'topico': widget.topico.id,
            'usuario_detail': {
              'id': userId,
              'user': userId,
              'username': jsonData['username'] ?? '',
              'profile_picture': jsonData['profile_picture'],
            },
            'conteudo': jsonData['message'] ?? '',
            'imagem': jsonData['imagem_url'],
            'capitulo': jsonData['capitulo'],
            'is_spoiler': jsonData['is_spoiler'] ?? false,
            'criado_em': criadoEm.toIso8601String(),
            'lidos_por': [],
          };

          final msg = Mensagem.fromJson(msgJson);

          if (mounted) {
            setState(() => mensagens.add(msg));

            Future.delayed(const Duration(milliseconds: 100), () {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        } catch (e) {
          debugPrint("Erro no parse do evento WS: $e");
        }
      });
    } catch (e) {
      debugPrint("Erro ao iniciar WebSocket: $e");
      socketConnected = false;
    }
  }

  // ================= AVATAR =================
  ImageProvider avatarProvider(String? url) {
    if (url != null && url.isNotEmpty) {
      return NetworkImage('${TopicPage.base}$url');
    }
    return const AssetImage("assets/img/placeholder.jpg");
  }

  // ================= MONTAR MENSAGEM =================
  Widget montarMensagem(Mensagem m) {
    final avatar = avatarProvider(m.usuario?.profilePicture);

    if (m.imagem != null && m.imagem!.isNotEmpty) {
      if (m.isSpoiler) {
        return ImageSpoilerMessage(
          avatar: avatar,
          chapter: m.capitulo ?? 0,
          image: '${TopicPage.base}${m.imagem!}',
          text: m.conteudo,
        );
      }
      return ImageMessage(
        image: '${TopicPage.base}${m.imagem!}',
        text: m.conteudo,
      );
    }

    if (m.usuario?.id == meuProfile?.id) {
      return MyMessage(text: m.conteudo);
    }

    if (m.isSpoiler) {
      return SpoilerMessage(
        avatar: avatar,
        chapter: m.capitulo ?? 0,
        text: m.conteudo,
      );
    }

    return TextMessage(
      avatar: avatar,
      text: m.conteudo,
      chapter: m.capitulo,
    );
  }

  // ================= FUNÇÕES DE ENVIO =================
  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked == null) return;
    setState(() => imagemSelecionada = picked);
  }

  Future<String?> imagemParaBase64() async {
    if (imagemSelecionada == null) return null;
    final bytes = await imagemSelecionada!.readAsBytes();
    final ext = p.extension(imagemSelecionada!.name).replaceFirst('.', '').toLowerCase();
    final mime = ext == 'jpg' || ext == 'jpeg' ? 'jpeg' : (ext == 'png' ? 'png' : ext);
    return 'data:image/$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> pedirCapitulo() async {
    final tc = TextEditingController();
    final res = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Número do capítulo (spoiler)"),
        content: TextField(
          controller: tc,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Ex: 3"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Cancelar")),
          TextButton(
              onPressed: () {
                final v = int.tryParse(tc.text.trim());
                Navigator.pop(ctx, v);
              },
              child: const Text("OK")),
        ],
      ),
    );

    if (res != null) {
      setState(() {
        spoilerCapitulo = res;
        spoilerMode = true;
      });
    } else {
      setState(() {
        spoilerCapitulo = null;
        spoilerMode = false;
      });
    }
  }

  Future<void> enviarMensagem() async {
    final texto = controller.text.trim();
    if ((texto.isEmpty && imagemSelecionada == null) || meuProfile == null) return;

    String? imagemBase64 = await imagemParaBase64();

    final data = {
      "type": "chat_message",
      "message": texto,
      "user_id": meuProfile!.id,
      "username": meuProfile!.username,
      "spoiler_capitulo": spoilerMode ? spoilerCapitulo : null,
      "imagem": imagemBase64,
    };

    try {
      socket.sendMessage(data);

      final novaMsg = Mensagem(
        id: mensagens.length + 1,
        topicoId: widget.topico.id,
        usuario: meuProfile,
        conteudo: texto,
        imagem: imagemSelecionada != null ? p.basename(imagemSelecionada!.name) : null,
        isSpoiler: spoilerMode,
        capitulo: spoilerCapitulo,
        criadoEm: DateTime.now(),
        lidosPor: [],
      );

      setState(() {
        controller.clear();
        imagemSelecionada = null;
        spoilerMode = false;
        spoilerCapitulo = null;
      });

      Future.delayed(const Duration(milliseconds: 150), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint("Erro ao enviar msg por socket: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar mensagem")));
    }
  }

  Widget buildImagePreview() {
    if (imagemSelecionada == null) return const SizedBox();

    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: imagemSelecionada!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                snapshot.data!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return const SizedBox(width: 64, height: 64);
          }
        },
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagemSelecionada!.path),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }
  }
  List<PopupMenuEntry<String>> _menuOpcoes(BuildContext context) {
  
      return [
        const PopupMenuItem(
          value: "avaliar",
          child: Text("Avaliar livro"),
        ),
      ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white.withOpacity(1.0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "#${widget.topico.nome}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
         PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.amber),
            itemBuilder: (context) => _menuOpcoes(context),
            onSelected: (value) async {
              switch (value) {
                case "avaliar":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResenhaPage(livro: widget.topico.livro!),
                    ),
                  );
                  break;
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/placeholder.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.35)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(top: 100, bottom: 20),
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) => montarMensagem(mensagens[index]),
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagemSelecionada != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        buildImagePreview(),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.basename(imagemSelecionada!.name))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => imagemSelecionada = null),
                        )
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (!spoilerMode) {
                            await pedirCapitulo();
                          } else {
                            setState(() {
                              spoilerMode = false;
                              spoilerCapitulo = null;
                            });
                          }
                        },
                        icon: Icon(
                          spoilerMode ? Icons.visibility : Icons.visibility_off,
                          color: Colors.purple.shade400,
                        ),
                      ),
                      IconButton(
                        onPressed: escolherImagem,
                        icon: Icon(Icons.photo, color: Colors.purple.shade400),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Mensagem...",
                            border: InputBorder.none,
                            suffix: spoilerMode && spoilerCapitulo != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Spoiler: cap ${spoilerCapitulo}",
                                      style: TextStyle(color: Colors.purple.shade700, fontSize: 12),
                                    ),
                                  )
                                : null,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => enviarMensagem(),
                        ),
                      ),
                      IconButton(
                        onPressed: enviarMensagem,
                        icon: Icon(Icons.send, color: Colors.purple.shade400),
                      )
                    ],
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

// ================= Mensagem Widgets =================

class SpoilerMessage extends StatefulWidget {
  final ImageProvider avatar;
  final int chapter;
  final String text;

  const SpoilerMessage({super.key, required this.avatar, required this.chapter, required this.text,});

  @override
  State<SpoilerMessage> createState() => _SpoilerMessageState();
}

class _SpoilerMessageState extends State<SpoilerMessage> {
  bool reveal = false;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        CircleAvatar(backgroundImage: widget.avatar),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reveal ? widget.text : "Spoiler capítulo ${widget.chapter}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => reveal = !reveal),
                  child: Text(
                    reveal ? "ocultar" : "mostrar",
                    style: TextStyle(
                      color: Colors.purple.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TextMessage extends StatelessWidget {
  final ImageProvider avatar;
  final String text;
  final int? chapter;

  const TextMessage({super.key, required this.avatar, required this.text, this.chapter});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        CircleAvatar(backgroundImage: avatar),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chapter != null)
                  Text(
                    "Spoiler capítulo $chapter",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MyMessage extends StatelessWidget {
  final String text;

  const MyMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(text),
          ),
        ),
      ],
    );
  }
}

class ImageMessage extends StatelessWidget {
  final String image;
  final String text;

  const ImageMessage({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              Image.network(image),
              if (text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white.withOpacity(0.8),
                  child: Text(text),
                )
            ],
          ),
        ),
      ],
    );
  }
}

class ImageSpoilerMessage extends StatefulWidget {
  final ImageProvider avatar;
  final int chapter;
  final String image;
  final String text;

  const ImageSpoilerMessage({super.key, required this.avatar, required this.chapter, required this.image, required this.text});

  @override
  State<ImageSpoilerMessage> createState() => _ImageSpoilerMessageState();
}

class _ImageSpoilerMessageState extends State<ImageSpoilerMessage> {
  bool reveal = false;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        CircleAvatar(backgroundImage: widget.avatar),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GestureDetector(
            onTap: () => setState(() => reveal = !reveal),
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  if (reveal) Image.network(widget.image),
                  Text(reveal ? widget.text : "Spoiler capítulo ${widget.chapter}"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
