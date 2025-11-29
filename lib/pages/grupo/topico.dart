import 'package:flutter/material.dart';

class TopicPage extends StatefulWidget {

  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final TextEditingController controller = TextEditingController();

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
          "#Tema: Príncipe Cruel",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert, color: Colors.amber),
          )
        ],
      ),

      body: Stack(
        children: [
          // ---------- Fundo borrado ----------
          Positioned.fill(
            child: Image.asset(
              "assets/img/placeholder.jpg", // troque para sua imagem
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.35),
            ),
          ),

          // ---------- Lista de mensagens ----------
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 20),
              children: [
                SpoilerMessage(
                  avatar: "assets/img/placeholder.jpg",
                  chapter: 29,
                ),

                SpoilerMessage(
                  avatar: "assets/img/placeholder.jpg",
                  chapter: 29,
                ),

                TextMessage(
                  avatar: "assets/img/placeholder.jpg",
                  text:
                      "Galera?? Eu me sinto mais e mais enganada a cada segundo",
                  chapter: 25,
                ),

                MyMessage(
                  text: "Tô lendo essa parte agr, nunca imaginei isso do Oak",
                ),

                TextMessage(
                  avatar: "assets/img/placeholder.jpg",
                  text:
                      "O Oak??? Eu quase não imaginei o Oak pra ele ter essa importância",
                  chapter: 25,
                ),

                SpoilerMessage(
                  avatar: "assets/img/placeholder.jpg",
                  chapter: 29,
                ),

                SpoilerMessage(
                  avatar: "assets/img/placeholder.jpg",
                  chapter: 29,
                ),

                ImageMessage(
                  image: "assets/img/placeholder.jpg",
                  text:
                      "E eu oficialmente tomei um ranço da Taryn, que menina chata!!",
                ),
              ],
            ),
          ),

          // ---------- Barra de digitação ----------
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_emotions_outlined,
                      color: Colors.purple.shade400),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Mensagem...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file, color: Colors.purple.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpoilerMessage extends StatefulWidget {
  final String avatar;
  final int chapter;

  const SpoilerMessage({
    super.key,
    required this.avatar,
    required this.chapter,
  });

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
        CircleAvatar(backgroundImage: AssetImage(widget.avatar)),
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
                    reveal
                        ? "Conteúdo do spoiler capítulo ${widget.chapter}"
                        : "Spoiler capítulo ${widget.chapter}",
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
  final String avatar;
  final String text;
  final int? chapter;

  const TextMessage({
    super.key,
    required this.avatar,
    required this.text,
    this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        CircleAvatar(backgroundImage: AssetImage(avatar)),
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

  const ImageMessage({
    super.key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(image),
                ),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          ),
        )
      ],
    );
  }
}

