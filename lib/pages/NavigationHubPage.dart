import 'package:flutter/material.dart';
import 'package:BookCLUB/pages/grupo/criarGrupo.dart';

class NavigationHubPage extends StatelessWidget {
  const NavigationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7B3AED);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text(
          "BookCLUB – Navegação",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              _buildButton(
                context,
                label: "Recuperar Senha (E-mail)",
                route: "/recoverEmail",
              ),

              _buildButton(
                context,
                label: "Inserir Nova Senha",
                route: "/newPassword",
              ),

              _buildButton(
                context,
                label: "Login",
                route: "/login",
              ),

              _buildButton(
                context,
                label: "Cadastro",
                route: "/signup",
              ),

              _buildButton(
                context,
                label: "Perfil do Usuário",
                route: "/perfil",
              ),

              _buildButton(
                context,
                label: "Página Inicial (Home)",
                route: "/home",
              ),

              _buildButton(
                context,
                label: "Página de Grupo",
                route: "/grupo",
              ),

              _buildButton(
                context,
                label: "Página de Busca",
                route: "/search",
              ),

              _buildButton(
                context,
                label: "Página de Busca de Usuários",
                route: "/search/membros",
              ),

              _buildButton(
                context,
                label: "Página de Criar Grupo",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateGrupoPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label, String? route, VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed ?? () {
          if (route != null) Navigator.pushNamed(context, route);
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
