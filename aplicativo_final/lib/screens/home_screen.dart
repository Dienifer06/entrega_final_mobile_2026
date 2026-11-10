import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../widgets/kawaii_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsuarioModel _usuario = UsuarioModel(nome: "Dev Aprendiz");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com a imagem da praça da cidade
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/cidade_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFFFF0F5),
              ),
            ),
          ),
          // Sombra suave sobre o fundo para destacar os botões
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  KawaiiHeader(
                    xp: _usuario.xp,
                    moedas: _usuario.moedas,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "Hello Kitty",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Minha Cidade Digital",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC71585),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Uma cidade conectada, muitas histórias para descobrir! 💕",
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Imagem da Hello Kitty na parte inferior esquerda
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 170,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/characters/hello_kitty.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.pets,
                              size: 100,
                              color: Color(0xFFFF69B4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMenuButton(
                              label: "Explorar Cidade",
                              icon: Icons.play_arrow_rounded,
                              isHighlight: true,
                              onPressed: () => Navigator.pushNamed(context, '/mapa'),
                            ),
                            _buildMenuButton(
                              label: "Comércios",
                              icon: Icons.storefront,
                              onPressed: () => Navigator.pushNamed(context, '/comercios'),
                            ),
                            _buildMenuButton(
                              label: "Eventos",
                              icon: Icons.calendar_month,
                              onPressed: () => Navigator.pushNamed(context, '/eventos'),
                            ),
                            _buildMenuButton(
                              label: "Oportunidades",
                              icon: Icons.work,
                              onPressed: () => Navigator.pushNamed(context, '/oportunidades'),
                            ),
                            _buildMenuButton(
                              label: "Serviços",
                              icon: Icons.account_balance,
                              onPressed: () => Navigator.pushNamed(context, '/servicos'),
                            ),
                            _buildMenuButton(
                              label: "Meu Perfil",
                              icon: Icons.person,
                              onPressed: () => Navigator.pushNamed(context, '/perfil'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isHighlight ? const Color(0xFFFF69B4) : Colors.white.withOpacity(0.95),
            foregroundColor: isHighlight ? Colors.white : const Color(0xFFFF69B4),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFFFB6C1), width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }
}