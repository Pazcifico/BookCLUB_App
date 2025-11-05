import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Pages
import 'package:BookCLUB/pages/user/login_page.dart';
import 'package:BookCLUB/pages/user/register_page.dart';
import 'package:BookCLUB/pages/user/usuario_page.dart';

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
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signup: (context) => const RegisterPage(),
        AppRoutes.perfil: (context) => const UsuarioPage(),
      },
    );
  }
}
