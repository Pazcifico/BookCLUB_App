import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final confirmEmailController = TextEditingController();

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
                      Text(
                        "BookCLUB",
                        style: TextStyle(
                          color: purple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // TÍTULO
                  Text(
                    "Recupere sua senha",
                    style: TextStyle(
                      color: purple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Enviaremos um código de recuperação para o seu e-mail.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // EMAIL
                  Text(
                    "E-mail",
                    style: TextStyle(
                      color: purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Digite seu e-mail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: purple),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Digite seu e-mail";
                      if (!value.contains("@")) return "E-mail inválido";
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // CONFIRMAR EMAIL
                  Text(
                    "Confirmar E-mail",
                    style: TextStyle(
                      color: purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: confirmEmailController,
                    decoration: InputDecoration(
                      hintText: "Confirme seu e-mail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: purple),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Confirme seu e-mail";
                      if (value != emailController.text) return "Os e-mails não coincidem";
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
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
