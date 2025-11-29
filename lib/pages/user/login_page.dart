import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BookCLUB/repositories/userRepository.dart';
import 'package:BookCLUB/config/routes.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await _userRepository.login(
      usernameOrEmail: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (token != null) {
      await _saveCredentials();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );

      // Navega para a página principal usando rota nomeada
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos')),
      );
    }
  }

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
                  Text("Faça seu login",
                      style: TextStyle(
                          color: purple,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      "Compartilhe livros e adentre novos mundos literários.",
                      style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 30),

                  // E-mail
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'Digite seu e-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: purple),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Digite seu e-mail';
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
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
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Digite sua senha' : null,
                  ),
                  const SizedBox(height: 10),

                  // Lembre-me
                  Row(
                    children: [
                      Checkbox(
                        activeColor: purple,
                        value: _rememberMe,
                        onChanged: (val) {
                          setState(() => _rememberMe = val ?? false);
                        },
                      ),
                      const Text("Lembre-me"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : _onLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("ENTRAR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ações secundárias
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // Navega usando rota nomeada
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        child: const Text("Criar Conta",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Esqueci minha senha",
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
