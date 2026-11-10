import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OportunidadesScreen extends StatefulWidget {
  const OportunidadesScreen({super.key});

  @override
  State<OportunidadesScreen> createState() => _OportunidadesScreenState();
}

class _OportunidadesScreenState extends State<OportunidadesScreen> {
  late Future<List<dynamic>> _futureOportunidades;
  String _filtroNivel = "Todos";
  String _termoPesquisa = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarOportunidades();
  }

  void _carregarOportunidades() {
    setState(() {
      _futureOportunidades = ApiService.getOportunidades();
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
              // 1. Cabeçalho em Fita Rosa
              _buildHeaderRibbon(
                icon: Icons.work_outline_rounded,
                titulo: "Oportunidades para Todos",
                subtitulo: "Encontra a vaga ideal e cumpre missões na cidade! 💕",
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 14),

              // 2. Barra de Pesquisa em Tempo Real
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _termoPesquisa = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Pesquisar vaga ou empresa...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFFF69B4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Filtros Rápidos por Nível
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Todos"),
                    _buildFilterChip("Ensino Médio"),
                    _buildFilterChip("Ensino Fundamental"),
                    _buildFilterChip("Técnico"),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Lista Dinâmica Consumindo da API Render
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _futureOportunidades,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF69B4)),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Erro ao carregar oportunidades da API.",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Nenhuma oportunidade registada na API."),
                      );
                    }

                    final listaCompleta = snapshot.data!;
                    final listaFiltrada = listaCompleta.where((item) {
                      final titulo = (item['titulo'] ?? '').toString().toLowerCase();
                      final empresa = (item['empresa'] ?? '').toString().toLowerCase();
                      final nivel = (item['nivel'] ?? '').toString();

                      final combinaPesquisa = _termoPesquisa.isEmpty ||
                          titulo.contains(_termoPesquisa) ||
                          empresa.contains(_termoPesquisa);

                      final combinaNivel = _filtroNivel == "Todos" || nivel == _filtroNivel;

                      return combinaPesquisa && combinaNivel;
                    }).toList();

                    if (listaFiltrada.isEmpty) {
                      return const Center(
                        child: Text("Nenhuma vaga corresponde aos filtros selecionados."),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        return _buildCardOportunidade(listaFiltrada[index]);
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

  Widget _buildCardOportunidade(dynamic item) {
    final String titulo = item['titulo'] ?? 'Vaga Disponível';
    final String empresa = item['empresa'] ?? 'Empresa Parceira';
    final String local = item['local'] ?? 'Centro';
    final String nivel = item['nivel'] ?? 'Geral';

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business_rounded, size: 15, color: Color(0xFFFF69B4)),
                const SizedBox(width: 6),
                Text(empresa, style: const TextStyle(fontSize: 12, color: Color(0xFF5A5A5A), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFFFF69B4)),
                const SizedBox(width: 6),
                Text(local, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(width: 14),
                const Icon(Icons.school_rounded, size: 15, color: Color(0xFFFF69B4)),
                const SizedBox(width: 6),
                Text(nivel, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
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
                            const Icon(Icons.star, color: Colors.amber, size: 15),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "+25 XP Missão",
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
                  onPressed: () => _abrirModalDetalhesVaga(item),
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text("Ver Detalhes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = _filtroNivel == label;
    return GestureDetector(
      onTap: () => setState(() => _filtroNivel = label),
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

  void _abrirModalDetalhesVaga(dynamic item) {
    final String titulo = item['titulo'] ?? 'Vaga';
    final String empresa = item['empresa'] ?? 'Empresa';
    final String descricao = item['descricao'] ?? 'Sem descrição adicional registada.';

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
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 4),
              Text(
                empresa,
                style: const TextStyle(fontSize: 13, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A5A), height: 1.4),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF529A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Candidatura enviada para "$titulo"! (+25 XP)')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text("Candidatar-me (+25 XP)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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