import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import './banco_local.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<dynamic>> _futureEventos;
  final Set<String> _nomesEventosFavoritos = {};

  @override
  void initState() {
    super.initState();
    _carregarFavoritosLocais();
    _carregarEventos();
  }

  Future<void> _carregarFavoritosLocais() async {
    final List<String> favsRaw = await BancoLocal.carregar('meus_favoritos');
    setState(() {
      _nomesEventosFavoritos.clear();
      for (var item in favsRaw) {
        if (item.contains('|')) {
          final partes = item.split('|');
          if (partes.isNotEmpty) _nomesEventosFavoritos.add(partes[0]);
        } else if (item.startsWith('{')) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            if (map['nome'] != null) _nomesEventosFavoritos.add(map['nome'].toString());
          } catch (_) {}
        }
      }
    });
  }

  void _carregarEventos() {
    setState(() {
      _futureEventos = ApiService.getEventos();
    });
  }

  Future<void> _toggleFavorito(dynamic evento) async {
    final String nome = evento['nome'] ?? 'Evento Especial';
    final String local = evento['local'] ?? 'Praça Central Kawaii';
    final String itemFormatado = "$nome|Evento|$local";

    final prefs = await SharedPreferences.getInstance();
    List<String> favsRaw = await BancoLocal.carregar('meus_favoritos');

    bool favoritado = false;
    if (_nomesEventosFavoritos.contains(nome)) {
      favsRaw.removeWhere((item) => item.startsWith(nome));
      _nomesEventosFavoritos.remove(nome);
    } else {
      favsRaw.add(itemFormatado);
      _nomesEventosFavoritos.add(nome);
      favoritado = true;

      await prefs.setBool('acao_evento', true);
      int xp = prefs.getInt('user_xp') ?? 145;
      int moedas = prefs.getInt('user_moedas') ?? 120;
      await prefs.setInt('user_xp', xp + 15);
      await prefs.setInt('user_moedas', moedas + 15);
    }

    await BancoLocal.salvarLista('meus_favoritos', favsRaw);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favoritado
                ? '❤️ "$nome" guardado nos Favoritos! (+15 XP / +15 Moedas)'
                : 'Removido dos Favoritos.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/backgrounds/circo_eventos.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFFFF0F5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderRibbon(
                    icon: Icons.calendar_month_rounded,
                    titulo: "Agenda de Eventos",
                    subtitulo: "Consulta os eventos comunitários e guarda os teus favoritos! 💕",
                    onBack: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/mapa');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _futureEventos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFF69B4)),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Erro ao carregar os eventos da API.",
                                style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Nenhum evento agendado neste momento."),
                          );
                        }

                        final eventos = snapshot.data!;
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: eventos.length,
                          itemBuilder: (context, index) {
                            final evento = eventos[index];
                            final String nome = evento['nome'] ?? '';
                            final bool isFav = _nomesEventosFavoritos.contains(nome);

                            return _buildCardEvento(evento, isFav);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEvento(dynamic evento, bool isFav) {
    final String nome = evento['nome'] ?? 'Evento Especial';
    final String data = evento['data'] ?? 'Sábado e Domingo';
    final String local = evento['local'] ?? 'Praça Central Kawaii';
    final String descricao = evento['descricao'] ?? 'Vem divertir-te com todas as atrações da cidade!';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? const Color(0xFFFF529A) : Colors.grey,
                    size: 26,
                  ),
                  onPressed: () => _toggleFavorito(evento),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFFF69B4)),
                const SizedBox(width: 6),
                Text(
                  data,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFFF69B4)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    local,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6A6A6A)),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFC0CB), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/ui/star_icon.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "+15 XP Participação",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF529A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => _abrirModalDetalhesEvento(evento),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text("Ver Detalhes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirModalDetalhesEvento(dynamic evento) {
    final String nome = evento['nome'] ?? 'Evento Especial';
    final String data = evento['data'] ?? 'Sábado e Domingo';
    final String local = evento['local'] ?? 'Praça Central Kawaii';
    final String descricao = evento['descricao'] ?? 'Descrição completa do evento com todas as atrações e horários.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nome,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/festa_primavera.png',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: const Color(0xFFFFF0F5),
                    child: const Icon(Icons.festival, size: 60, color: Color(0xFFFF69B4)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFFFF529A), size: 18),
                  const SizedBox(width: 6),
                  Text(data, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A5A5A))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.place_rounded, color: Color(0xFFFF529A), size: 18),
                  const SizedBox(width: 6),
                  Text(local, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A5A), height: 1.4),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF529A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('acao_evento', true);
                    int xp = prefs.getInt('user_xp') ?? 145;
                    int moedas = prefs.getInt('user_moedas') ?? 120;
                    await prefs.setInt('user_xp', xp + 15);
                    await prefs.setInt('user_moedas', moedas + 15);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Presença confirmada em "$nome"! (+15 XP / +15 Moedas)')),
                      );
                    }
                  },
                  child: const Text("Confirmar Presença (+15 XP)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderRibbon({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onBack,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFFF69B4), size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitulo, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}