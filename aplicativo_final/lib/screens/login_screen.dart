import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _lembrarSessao = true;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  // Verifica se o utilizador já está autenticado no cache local
  Future<void> _verificarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final bool logado = prefs.getBool('is_logged_in') ?? false;
    if (logado && mounted) {
      Navigator.pushReplacementNamed(context, '/mapa');
    }
  }

  // Efetua a autenticação e guarda os dados localmente (Critério 7)
  Future<void> _efetuarLogin() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche o utilizador e a palavra-passe! 💕'),
          backgroundColor: Color(0xFFFF529A),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', _lembrarSessao);
    await prefs.setString('user_name', usuario);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo(a), $usuario! 🎀')),
      );
      Navigator.pushReplacementNamed(context, '/mapa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone / Ilustração Kawaii
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFB6C1), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 60,
                    color: Color(0xFFFF69B4),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Text(
                  "Minha Cidade Digital",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF529A),
                  ),
                ),
                const Text(
                  "Efetua o login para explorar a cidade 💕",
                  style: TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
                ),
                const SizedBox(height: 30),

                // Campo Utilizador
                _buildTextField(
                  controller: _usuarioController,
                  label: "Utilizador / E-mail",
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),

                // Campo Palavra-passe
                _buildTextField(
                  controller: _senhaController,
                  label: "Palavra-passe",
                  icon: Icons.lock_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 10),

                // Opção Guardar Sessão
                Row(
                  children: [
                    Checkbox(
                      value: _lembrarSessao,
                      activeColor: const Color(0xFFFF529A),
                      onChanged: (val) {
                        setState(() {
                          _lembrarSessao = val ?? true;
                        });
                      },
                    ),
                    const Text(
                      "Lembrar da minha sessão",
                      style: TextStyle(fontSize: 12, color: Color(0xFF5A5A5A)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Botão de Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF529A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _efetuarLogin,
                    child: const Text(
                      "ENTRAR NO APP 🎀",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Entrar como Convidado
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/mapa');
                  },
                  child: const Text(
                    "Entrar como Convidado",
                    style: TextStyle(
                      color: Color(0xFFFF69B4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFFF69B4), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFFFF69B4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}