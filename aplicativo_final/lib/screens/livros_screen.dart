import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import './banco_local.dart';

class LivrosScreen extends StatefulWidget {
  const LivrosScreen({super.key});

  @override
  State<LivrosScreen> createState() => _LivrosScreenState();
}

class _LivrosScreenState extends State<LivrosScreen> {
  late Future<List<dynamic>> _futureLivros;
  final TextEditingController _searchController = TextEditingController();
  String _termoBusca = "alice";

  @override
  void initState() {
    super.initState();
    _searchController.text = _termoBusca;
    _carregarLivros(_termoBusca);
  }

  void _carregarLivros(String termo) {
    setState(() {
      _futureLivros = ApiService.buscarLivrosOpenLibrary(termo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderRibbon(
                icon: Icons.menu_book_rounded,
                titulo: "Biblioteca Kawaii",
                subtitulo: "Descobre livros na Open Library! 📚💕",
                onBack: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/mapa');
                  }
                },
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _termoBusca = value.trim();
                      _carregarLivros(_termoBusca);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Pesquisar livro...",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF69B4)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFFFF529A), size: 20),
                      onPressed: () {
                        if (_searchController.text.trim().isNotEmpty) {
                          _termoBusca = _searchController.text.trim();
                          _carregarLivros(_termoBusca);
                        }
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTagChip("Alice"),
                    _buildTagChip("Hello Kitty"),
                    _buildTagChip("Infantil"),
                    _buildTagChip("Aventura"),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _futureLivros,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF69B4)),
                            SizedBox(height: 12),
                            Text(
                              "A consultar Open Library...",
                              style: TextStyle(color: Color(0xFFFF529A), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Nenhum livro encontrado."),
                      );
                    }

                    final livros = snapshot.data!;
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: livros.length,
                      itemBuilder: (context, index) {
                        return _buildCardLivro(livros[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLivro(dynamic item) {
    final String titulo = item['title'] ?? 'Sem Título';
    final List<dynamic>? autores = item['author_name'];
    final String autor = (autores != null && autores.isNotEmpty) ? autores.first.toString() : 'Autor Desconhecido';
    final int? coverId = item['cover_i'];
    final String coverUrl = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () => _abrirModalDetalhesLivro(item, coverUrl),
        leading: Container(
          width: 48,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFC0CB), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.book_rounded,
                      color: Color(0xFFFF69B4),
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.book_rounded,
                    color: Color(0xFFFF69B4),
                    size: 28,
                  ),
          ),
        ),
        title: Text(
          titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF4A4A4A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Autor: $autor",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF529A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => _abrirModalDetalhesLivro(item, coverUrl),
          child: const Text("Ver +", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    final selected = _termoBusca.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _termoBusca = label;
        _carregarLivros(label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF529A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF529A) : const Color(0xFFFFB6C1),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xFF5A5A5A),
          ),
        ),
      ),
    );
  }

  void _abrirModalDetalhesLivro(dynamic item, String coverUrl) {
    final String titulo = item['title'] ?? 'Livro Sem Título';
    final List<dynamic>? autores = item['author_name'];
    final String autor = (autores != null && autores.isNotEmpty) ? autores.join(', ') : 'Autor Desconhecido';
    final int? ano = item['first_publish_year'];
    final int? edicoes = item['edition_count'];
    final List<dynamic>? editoras = item['publisher'];
    final String editora = (editoras != null && editoras.isNotEmpty) ? editoras.first.toString() : 'Não informada';

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
              if (coverUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    coverUrl,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.menu_book_rounded,
                      size: 70,
                      color: Color(0xFFFF69B4),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 6),
              Text(
                "Autor(es): $autor",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC0CB), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (ano != null)
                      Column(
                        children: [
                          const Text("Ano", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text("$ano", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                        ],
                      ),
                    if (edicoes != null)
                      Column(
                        children: [
                          const Text("Edições", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text("$edicoes", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                        ],
                      ),
                    Column(
                      children: [
                        const Text("Editora", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(
                          editora.length > 12 ? "${editora.substring(0, 10)}..." : editora,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF529A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    // Guarda o livro no BancoLocal usando o delimitador '|'
                    final String livroFormatado = "$titulo|$autor|$coverUrl";
                    await BancoLocal.salvar('meus_livros', livroFormatado);

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('acao_livro', true);

                    int xp = prefs.getInt('user_xp') ?? 145;
                    int moedas = prefs.getInt('user_moedas') ?? 120;
                    await prefs.setInt('user_xp', xp + 15);
                    await prefs.setInt('user_moedas', moedas + 15);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('📖 "$titulo" adicionado ao teu Perfil! (+15 XP / +15 Moedas)')),
                      );
                    }
                  },
                  icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                  label: const Text("Adicionar à Lista de Leitura (+15 XP)", style: TextStyle(fontWeight: FontWeight.bold)),
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