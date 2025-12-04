import 'dart:typed_data';
import 'package:BookCLUB/config/routes.dart';
import 'package:BookCLUB/config/api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';

class EditGrupoPage extends StatefulWidget {
  final Grupo grupo;
  static final String base = ApiConfig.baseUrl + "/media/";

  const EditGrupoPage({super.key, required this.grupo});

  @override
  State<EditGrupoPage> createState() => _EditGrupoPageState();
}

class _EditGrupoPageState extends State<EditGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;

  bool _privado = false;
  XFile? _imagem;
  Uint8List? _webImageBytes;
  bool _isLoading = false;

  final GrupoRepository _repository = GrupoRepository();

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.grupo.nome);
    _descricaoController = TextEditingController(
      text: widget.grupo.descricao ?? "",
    );

    // resolve erro de tipo bool? → bool
    _privado = widget.grupo.privado ?? false;
  }

  // Escolher imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _webImageBytes = await pickedFile.readAsBytes();
      setState(() => _imagem = pickedFile);
    }
  }

  ImageProvider _buildImageProvider() {
    // Se escolheu nova imagem → MemoryImage
    if (_webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    }

    // Se já existe imagem no grupo → carregar do servidor
    if (widget.grupo.imagem != null && widget.grupo.imagem!.isNotEmpty) {
      return NetworkImage("${EditGrupoPage.base}${widget.grupo.imagem!}");
    }

    // Imagem padrão caso não tenha nada
    return const AssetImage("assets/images/default_group.png");
  }

  // Enviar form
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final grupoAtualizado = Grupo(
        id: widget.grupo.id,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isEmpty
            ? null
            : _descricaoController.text,
        privado: _privado,
        imagem: widget.grupo.imagem,
      );

      bool sucesso = await _repository.editarGrupo(
        grupo: grupoAtualizado,
        imagem: _imagem,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          sucesso ? "Grupo atualizado com sucesso!" : "Erro ao editar grupo.",
        ),
      ));

      if (sucesso) Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao editar grupo: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(imageProvider),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ImageProvider imageProvider) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: const Color(0xFFFFC107),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.purple),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: "Nome do Grupo",
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? "Digite o nome do grupo" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: "Descrição",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_privado ? "Grupo Privado" : "Grupo Público"),
              Switch(
                value: _privado,
                onChanged: (v) => setState(() => _privado = v),
                activeColor: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Salvar mudanças",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
