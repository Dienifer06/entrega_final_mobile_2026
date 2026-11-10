import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  late Future<List<dynamic>> _futureServicos;
  String _categoriaSelecionada = "Todas";

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  void _carregarServicos() {
    setState(() {
      _futureServicos = ApiService.getServicos();
    });
  }

  IconData _getIconePorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'saúde':
      case 'saude':
        return Icons.add_box_rounded;
      case 'educação':
      case 'educacao':
        return Icons.school_rounded;
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'assistência social':
      case 'assistencia social':
        return Icons.favorite_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  Color _getCorPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'saúde':
      case 'saude':
        return Colors.redAccent;
      case 'educação':
      case 'educacao':
        return Colors.blueAccent;
      case 'transporte':
        return Colors.amber.shade700;
      case 'assistência social':
      case 'assistencia social':
        return const Color(0xFFFF529A);
      default:
        return const Color(0xFFFF69B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo Temático com predio_servicos.png
            Positioned.fill(
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/backgrounds/predio_servicos.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFFFF0F5),
                  ),
                ),
              ),
            ),

            // Conteúdo Principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Cabeçalho em Fita Rosa
                  _buildHeaderRibbon(
                    icon: Icons.account_balance_rounded,
                    titulo: "Central de Serviços",
                    subtitulo: "Encontra serviços públicos e informações úteis da cidade! 💕",
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 14),

                  // 2. Filtros por Categorias
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip("Todas"),
                        _buildCategoryChip("Saúde"),
                        _buildCategoryChip("Educação"),
                        _buildCategoryChip("Transporte"),
                        _buildCategoryChip("Assistência Social"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Lista Dinâmica de Serviços Públicos
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _futureServicos,
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
                                "Erro ao carregar serviços públicos da API.",
                                style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Nenhum serviço disponível de momento."),
                          );
                        }

                        final servicos = snapshot.data!;
                        final servicosFiltrados = _categoriaSelecionada == "Todas"
                            ? servicos
                            : servicos.where((s) => s['categoria'] == _categoriaSelecionada).toList();

                        if (servicosFiltrados.isEmpty) {
                          return const Center(
                            child: Text("Nenhum serviço encontrado nesta categoria."),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: servicosFiltrados.length,
                          itemBuilder: (context, index) {
                            return _buildCardServico(servicosFiltrados[index]);
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

  Widget _buildCardServico(dynamic item) {
    final String titulo = item['titulo'] ?? 'Serviço Público';
    final String categoria = item['categoria'] ?? 'Geral';
    final String horario = item['horario'] ?? 'Seg. a Sex. das 08:00 às 17:00';
    final IconData icone = _getIconePorCategoria(categoria);
    final Color cor = _getCorPorCategoria(categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: cor, width: 1.5),
          ),
          child: Icon(icone, color: cor, size: 26),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A4A4A)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  horario,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF529A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          onPressed: () => _abrirModalDetalhesServico(item),
          child: const Text("Informações", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final selected = _categoriaSelecionada == label;
    return GestureDetector(
      onTap: () => setState(() => _categoriaSelecionada = label),
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

  void _abrirModalDetalhesServico(dynamic item) {
    final String titulo = item['titulo'] ?? 'Serviço Público';
    final String categoria = item['categoria'] ?? 'Geral';
    final String horario = item['horario'] ?? 'Seg. a Sex. das 08:00 às 17:00';
    final String endereco = item['endereco'] ?? 'Endereço Central';
    final String telefone = item['telefone'] ?? '(11) 4000-0000';
    final String descricao = item['descricao'] ?? 'Sem informação detalhada.';
    final IconData icone = _getIconePorCategoria(categoria);
    final Color cor = _getCorPorCategoria(categoria);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, color: cor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                        ),
                        Text(
                          "Categoria: $categoria",
                          style: const TextStyle(fontSize: 12, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFFFD1DC)),
              _buildInfoRow(Icons.access_time_filled_rounded, "Horário de Funcionamento", horario),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.location_on_rounded, "Endereço", endereco),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.phone_rounded, "Contacto Directo", telefone),
              const SizedBox(height: 14),
              const Text("Descrição do Serviço:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A4A4A))),
              const SizedBox(height: 4),
              Text(
                descricao,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6A6A6A), height: 1.4),
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
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Informações de "$titulo" guardadas! (+10 XP)')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                  label: const Text("Guardar Informações (+10 XP)", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF69B4)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A4A), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
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