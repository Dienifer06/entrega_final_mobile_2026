import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. LayoutBuilder para calcular percentagens dinâmicas do ecrã
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 2.5,
                  child: Stack(
                    children: [
                      // Imagem de Fundo do Mapa Kawaii
                      Image.asset(
                        'assets/backgrounds/mapa_bg.png',
                        width: width,
                        height: height,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFFFE4E1),
                          child: const Center(
                            child: Icon(Icons.map_rounded, size: 80, color: Color(0xFFFF69B4)),
                          ),
                        ),
                      ),

                      // Pino 1: Comércios (Loja Rosa - Topo Esquerdo)
                      _buildMapPin(
                        context: context,
                        top: height * 0.18,
                        left: width * 0.17,
                        label: "Comércios",
                        icon: Icons.storefront_rounded,
                        route: '/comercios',
                      ),

                      // Pino 2: Eventos (Tenda de Circo - Topo Direito)
                      _buildMapPin(
                        context: context,
                        top: height * 0.20,
                        left: width * 0.75,
                        label: "Eventos",
                        icon: Icons.calendar_month_rounded,
                        route: '/eventos',
                      ),

                      // Pino 3: Biblioteca (Praça Central / Chafariz)
                      _buildMapPin(
                        context: context,
                        top: height * 0.42,
                        left: width * 0.46,
                        label: "Biblioteca",
                        icon: Icons.menu_book_rounded,
                        route: '/livros',
                      ),

                      // Pino 4: Serviços (Edifício com Relógio - Baixo Esquerdo)
                      _buildMapPin(
                        context: context,
                        top: height * 0.58,
                        left: width * 0.12,
                        label: "Serviços",
                        icon: Icons.account_balance_rounded,
                        route: '/servicos',
                      ),

                      // Pino 5: Oportunidades (Casa Azul com Estrela - Baixo Direito)
                      _buildMapPin(
                        context: context,
                        top: height * 0.58,
                        left: width * 0.74,
                        label: "Oportunidades",
                        icon: Icons.work_outline_rounded,
                        route: '/oportunidades',
                      ),
                    ],
                  ),
                );
              },
            ),

            // 2. Barra Superior de Navegação
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFFFB6C1), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: Color(0xFFFF529A), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Minha Cidade Digital",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/perfil'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF529A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Perfil",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente Reutilizável de Pino no Mapa
  Widget _buildMapPin({
    required BuildContext context,
    required double top,
    required double left,
    required String label,
    required IconData icon,
    required String route,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF529A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}