import 'package:flutter/material.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7B3EFF);
    final yellow = const Color(0xFFF5B800);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  // LOGO
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: purple, size: 28),
                      const SizedBox(width: 8),
                      Text("BookCLUB",
                          style: TextStyle(
                              color: purple,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // TÍTULO
                  Text(
                    "Insira sua nova senha",
                    style: TextStyle(
                      color: purple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Crie uma nova senha segura para sua conta.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SENHA
                  Text(
                    "Senha",
                    style: TextStyle(
                      color: purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Digite sua nova senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: purple),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: purple,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Digite sua senha" : null,
                  ),

                  const SizedBox(height: 20),

                  // CONFIRMAR SENHA
                  Text(
                    "Confirmar Senha",
                    style: TextStyle(
                      color: purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      hintText: "Confirme sua nova senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: purple),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: purple,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirme sua senha";
                      }
                      if (value != passwordController.text) {
                        return "As senhas não coincidem";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // BOTÃO ENVIAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // ação ao enviar
                        }
                      },
                      child: Text(
                        "ENVIAR",
                        style: TextStyle(
                          color: purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
