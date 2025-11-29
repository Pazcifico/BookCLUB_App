import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:BookCLUB/models/grupo_model.dart';
import 'package:BookCLUB/models/profile_model.dart';

// Pages
import 'package:BookCLUB/pages/user/login_page.dart';
import 'package:BookCLUB/pages/user/register_page.dart';
import 'package:BookCLUB/pages/user/usuario_page.dart';
import 'package:BookCLUB/pages/user/recuperar_senha.dart';
import 'package:BookCLUB/pages/user/nova_senha.dart';
import 'package:BookCLUB/pages/NavigationHubPage.dart';
import 'package:BookCLUB/pages/user/perfil.dart';
import 'package:BookCLUB/pages/home.dart';
import 'package:BookCLUB/pages/grupo/grupo.dart';
import 'package:BookCLUB/pages/search.dart';
import 'package:BookCLUB/pages/grupo/topico.dart';
import 'package:BookCLUB/pages/grupo/searchMembros.dart';
// Config
import 'package:BookCLUB/config/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const BookClubApp());
}

class BookClubApp extends StatelessWidget {
  const BookClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookCLUB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B3EFF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.hub,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signup: (context) => const RegisterPage(),
        AppRoutes.perfil: (context) => const ProfilePage(),
        AppRoutes.recuperarSenha: (context) => const ForgotPasswordPage(),
        AppRoutes.novaSenha: (context) => const NewPasswordPage(),
        AppRoutes.hub: (context) => const NavigationHubPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.search: (context) => const SearchPage(),
        AppRoutes.topic: (context) => const TopicPage(),
        AppRoutes.searchMembros: (context) => const SearchMembros(),
      },

      onGenerateRoute: (settings) {
  final args = settings.arguments;

  switch (settings.name) {
    case AppRoutes.group:
      if (args is Grupo) {
        return MaterialPageRoute(
          builder: (_) => GroupPage(grupo: args),
        );
      }
      break;

    case AppRoutes.user:
      if (args is Profile) {
        return MaterialPageRoute(
          builder: (_) => UserPage(profile: args),
        );
      }
      break;
  }

  // Se chegou aqui, é porque o argumento estava errado
  return MaterialPageRoute(
    builder: (_) => const Scaffold(
      body: Center(child: Text("Argumento inválido para esta rota.")),
    ),
  );
},

    );
  }
}
