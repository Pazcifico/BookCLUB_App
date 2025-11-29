import 'dart:typed_data';
import 'package:BookCLUB/config/routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/repositories/grupoRepository.dart';

class CreateGrupoPage extends StatefulWidget {
  final List<int>? membrosSelecionados;

  const CreateGrupoPage({super.key, this.membrosSelecionados});

  @override
  State<CreateGrupoPage> createState() => _CreateGrupoPageState();
}

class _CreateGrupoPageState extends State<CreateGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _privado = false;
  XFile? _imagem;
  Uint8List? _webImageBytes; // para Web e Mobile
  bool _isLoading = false;

  final GrupoRepository _repository = GrupoRepository();

  // Escolher imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        _webImageBytes = await pickedFile.readAsBytes();
      } else {
        _webImageBytes = await pickedFile.readAsBytes(); // Mobile também funciona
      }
      setState(() => _imagem = pickedFile);
    }
  }

  ImageProvider? _buildImageProvider() {
    if (_imagem == null || _webImageBytes == null) return null;
    return MemoryImage(_webImageBytes!); // funciona Web e Mobile
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final novoGrupo = Grupo(
        id: null,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isNotEmpty ? _descricaoController.text : null,
        privado: _privado,
        imagem: _imagem?.path,
      );
      print(widget.membrosSelecionados);

      bool sucesso = await _repository.criarGrupo(
        grupo: novoGrupo,
        imagem: _imagem,
        membros: widget.membrosSelecionados ?? [],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sucesso ? 'Grupo criado com sucesso!' : 'Erro ao criar grupo.')),
      );

      if (sucesso) Navigator.pushNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar grupo: $e')),
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

  Widget _buildHeader(ImageProvider? imageProvider) {
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
              child: imageProvider == null
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                  : null,
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
              labelText: 'Nome do Grupo',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Digite o nome do grupo' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_privado ? 'Grupo Privado' : 'Grupo Público'),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Criar Grupo',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
