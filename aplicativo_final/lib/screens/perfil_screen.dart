import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './banco_local.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  int xpAtual = 145;
  int xpProximoNivel = 200;
  int nivelAtual = 3;
  int moedasAtual = 120;

  List<Map<String, dynamic>> livrosEscolhidos = [];
  List<Map<String, dynamic>> meusFavoritos = [];
  
  bool apoiouComercio = false;
  bool adicionouLivro = false;
  bool participouEvento = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  Future<void> _carregarDadosPerfil() async {
    final prefs = await SharedPreferences.getInstance();

    final int xp = prefs.getInt('user_xp') ?? 145;
    final int moedas = prefs.getInt('user_moedas') ?? 120;
    final int nivel = (xp / 50).floor() + 1;

    final bool c = prefs.getBool('acao_comercio') ?? false;
    final bool l = prefs.getBool('acao_livro') ?? false;
    final bool e = prefs.getBool('acao_evento') ?? false;

    // Carrega Livros Guardados via BancoLocal
    final List<String> livrosRaw = await BancoLocal.carregar('meus_livros');
    List<Map<String, dynamic>> listaLivros = [];
    for (String item in livrosRaw) {
      if (item.trim().isEmpty) continue;
      if (item.trim().startsWith('{')) {
        try {
          listaLivros.add(jsonDecode(item) as Map<String, dynamic>);
          continue;
        } catch (_) {}
      }
      final partes = item.split('|');
      listaLivros.add({
        "titulo": partes.isNotEmpty ? partes[0] : "Livro",
        "autor": partes.length > 1 ? partes[1] : "Desconhecido",
        "capa": partes.length > 2 ? partes[2] : "",
      });
    }

    // Carrega Favoritos Guardados via BancoLocal
    final List<String> favsRaw = await BancoLocal.carregar('meus_favoritos');
    List<Map<String, dynamic>> listaFavs = [];
    for (String item in favsRaw) {
      if (item.trim().isEmpty) continue;
      if (item.trim().startsWith('{')) {
        try {
          listaFavs.add(jsonDecode(item) as Map<String, dynamic>);
          continue;
        } catch (_) {}
      }
      final partes = item.split('|');
      listaFavs.add({
        "nome": partes.isNotEmpty ? partes[0] : "Favorito",
        "categoria": partes.length > 1 ? partes[1] : "Evento",
        "local": partes.length > 2 ? partes[2] : "Cidade",
      });
    }

    if (mounted) {
      setState(() {
        xpAtual = xp;
        moedasAtual = moedas;
        nivelAtual = nivel;
        apoiouComercio = c;
        adicionouLivro = l || listaLivros.isNotEmpty;
        participouEvento = e || listaFavs.isNotEmpty;
        livrosEscolhidos = listaLivros;
        meusFavoritos = listaFavs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progressoXp = (xpAtual / xpProximoNivel).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF69B4),
          onRefresh: _carregarDadosPerfil,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRibbon(
                  icon: Icons.arrow_back_rounded,
                  titulo: "Meu Perfil Kawaii",
                  subtitulo: "Acompanha as tuas conquistas, livros e moedas! 💕",
                  onBack: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/mapa');
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildCardPerfil(progressoXp),
                const SizedBox(height: 20),
                _buildSectionTitle("Como Ganhar Moedas 🪙", Icons.monetization_on_rounded),
                const SizedBox(height: 10),
                _buildAcoesGanharMoedas(),
                const SizedBox(height: 20),
                _buildSectionTitle("Meus Livros Escolhidos 📚", Icons.collections_bookmark_rounded),
                const SizedBox(height: 10),
                _buildLivrosEscolhidos(),
                const SizedBox(height: 20),
                _buildSectionTitle("Meus Favoritos ❤️", Icons.favorite_rounded),
                const SizedBox(height: 10),
                _buildMeusFavoritos(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String titulo, IconData icone) {
    return Row(
      children: [
        Icon(icone, color: const Color(0xFFFF529A), size: 22),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
        ),
      ],
    );
  }

  Widget _buildCardPerfil(double progressoXp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF69B4), width: 3),
                ),
                child: Image.asset(
                  'assets/characters/hello_kitty.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.face, size: 50, color: Color(0xFFFF69B4)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF529A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  "Nív. $nivelAtual",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Cidadão Hello Kitty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Experiência (XP)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5A5A5A))),
                  Text("$xpAtual / $xpProximoNivel XP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFF529A))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressoXp,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFFFF0F5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF529A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFC0CB), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  "$moedasAtual Moedas Acumuladas",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFFF529A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoesGanharMoedas() {
    final acoes = [
      {
        "titulo": "Apoiar um Comércio Local",
        "recompensa": "+20 Moedas & +20 XP",
        "concluido": apoiouComercio,
        "icone": Icons.storefront_rounded,
        "rota": '/comercios',
      },
      {
        "titulo": "Adicionar Livro à Lista de Leitura",
        "recompensa": "+15 Moedas & +15 XP",
        "concluido": adicionouLivro,
        "icone": Icons.menu_book_rounded,
        "rota": '/livros',
      },
      {
        "titulo": "Confirmar Presença num Evento",
        "recompensa": "+15 Moedas & +15 XP",
        "concluido": participouEvento,
        "icone": Icons.festival_rounded,
        "rota": '/eventos',
      },
    ];

    return Column(
      children: acoes.map((item) {
        final bool concluido = item['concluido'] as bool;
        final String rota = item['rota'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFFF0F5), shape: BoxShape.circle),
                child: Icon(item['icone'] as IconData, color: const Color(0xFFFF529A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['titulo'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A4A4A))),
                    Text(item['recompensa'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFFFF529A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              concluido
                  ? _buildChip("Concluído ✔️", Colors.green)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF529A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, rota);
                        _carregarDadosPerfil();
                      },
                      child: const Text("Ir Fazer", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLivrosEscolhidos() {
    if (livrosEscolhidos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
        ),
        child: const Text(
          "Nenhum livro adicionado ainda. Explora a Biblioteca Kawaii! 📚",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: livrosEscolhidos.map((livro) {
        final String capa = (livro['capa'] ?? '').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFC0CB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: capa.startsWith('http')
                      ? Image.network(capa, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.book, color: Color(0xFFFF69B4)))
                      : const Icon(Icons.book_rounded, color: Color(0xFFFF69B4)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livro['titulo'] ?? 'Livro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A4A4A)),
                    ),
                    Text(
                      "Autor: ${livro['autor'] ?? 'Desconhecido'}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bookmark_added_rounded, color: Color(0xFFFF529A), size: 22),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMeusFavoritos() {
    if (meusFavoritos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
        ),
        child: const Text(
          "Nenhum favorito guardado. Clica no ❤️ dos eventos para adicionar!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: meusFavoritos.map((fav) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.festival_rounded, color: Color(0xFFFF529A), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav['nome'] ?? 'Favorito',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A4A4A)),
                    ),
                    Text(
                      "${fav['categoria'] ?? 'Evento'} • ${fav['local'] ?? 'Cidade'}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite_rounded, color: Color(0xFFFF529A), size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
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