import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ComerciosScreen extends StatefulWidget {
  const ComerciosScreen({super.key});

  @override
  State<ComerciosScreen> createState() => _ComerciosScreenState();
}

class _ComerciosScreenState extends State<ComerciosScreen> {
  final TextEditingController nomeDigitado = TextEditingController();
  final TextEditingController precoDigitado = TextEditingController();
  final TextEditingController urlDigitado = TextEditingController();

  List<String> mostrarProdutos = [];
  bool carregando = true;
  String categoriaSelecionada = "Docerias";

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  // =========================================================================
  // 1. READ / GET HÍBRIDO: Unifica a API com o Banco Local para não perder itens
  // =========================================================================
  void carregarProdutos() async {
    setState(() => carregando = true);
    SharedPreferences banco = await SharedPreferences.getInstance();

    // A. Carrega o que já está guardado localmente no dispositivo
    List<String> dadosLocais = banco.getStringList("produtos") ?? [];

    // B. Tenta procurar os produtos na API do Render
    List<dynamic> dadosApi = await ApiService.getProdutos();
    List<String> listaApiFormatada = [];

    if (dadosApi.isNotEmpty) {
      for (var item in dadosApi) {
        String id = (item['id'] ?? '').toString();
        String nome = (item['nome'] ?? 'Sem Nome').toString().trim();
        String preco = (item['preco'] ?? 0.0).toString();
        String cat = (item['categoria'] ?? 'Docerias').toString().trim();
        String img = (item['imagem'] ?? 'assets/items/bolo_morango.png').toString().trim();

        listaApiFormatada.add("$nome|$preco|$cat|$img|$id");
      }
    }

    // C. Unifica os dados da API com os dados Locais (evita duplicados e mantém o que salvou)
    Set<String> conjuntoUnificado = {...dadosLocais, ...listaApiFormatada};
    List<String> listaFinal = conjuntoUnificado.toList();

    // Se o banco estiver completamente vazio, insere exemplos iniciais
    if (listaFinal.isEmpty) {
      listaFinal = [
        "Loja de Doces Kawaii|15.00|Docerias|assets/items/bolo_morango.png|1",
        "Laços & Acessórios|25.00|Acessórios|assets/items/laco_rosa.png|2",
        "Papelaria Hello Kitty|10.00|Papelaria|assets/items/pelucia_kitty.png|3",
      ];
    }

    // Atualiza a cache no SharedPreferences sem apagar o que o utilizador salvou
    await banco.setStringList("produtos", listaFinal);

    if (mounted) {
      setState(() {
        mostrarProdutos = listaFinal;
        carregando = false;
      });
    }
  }

  // =========================================================================
  // 2. CREATE / POST: Envia para a API e persiste no Banco Local (se offline)
  // =========================================================================
  void salvarProduto() async {
    if (nomeDigitado.text.trim().isEmpty || precoDigitado.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preenche pelo menos o nome e o preço! 💕")),
      );
      return;
    }

    final double precoVal = double.tryParse(precoDigitado.text.trim()) ?? 0.0;
    final String imagemVal = urlDigitado.text.trim().isNotEmpty
        ? urlDigitado.text.trim()
        : "assets/items/bolo_morango.png";

    Map<String, dynamic> novoProduto = {
      "nome": nomeDigitado.text.trim(),
      "preco": precoVal,
      "categoria": categoriaSelecionada,
      "imagem": imagemVal,
    };

    bool apiOk = await ApiService.criarProduto(novoProduto);

    SharedPreferences banco = await SharedPreferences.getInstance();

    // Só guarda no banco local com ID temporário se a API falhar.
    // Se tiver sucesso, o carregarProdutos() vai puxar o item com o ID real!
    if (!apiOk) {
      String idTemp = "temp_${DateTime.now().millisecondsSinceEpoch}";
      String itemFormatado = "${nomeDigitado.text.trim()}|$precoVal|$categoriaSelecionada|$imagemVal|$idTemp";

      List<String> listaLocal = banco.getStringList("produtos") ?? [];
      listaLocal.add(itemFormatado);
      await banco.setStringList("produtos", listaLocal);
    }

    // Gamificação (+20 XP / +20 Moedas)
    await banco.setBool('acao_comercio', true);
    int xp = banco.getInt('user_xp') ?? 145;
    int moedas = banco.getInt('user_moedas') ?? 120;
    await banco.setInt('user_xp', xp + 20);
    await banco.setInt('user_moedas', moedas + 20);

    nomeDigitado.clear();
    precoDigitado.clear();
    urlDigitado.clear();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiOk
                ? "Comércio registado na API com sucesso! 💕 (+20 XP)"
                : "API falhou. Guardado no banco local (offline)! (+20 XP)",
          ),
        ),
      );
    }

    carregarProdutos();
  }

  // =========================================================================
  // 3. UPDATE / PUT: Atualiza na API e no Banco Local
  // =========================================================================
  void editarProduto(String produtoAntigo) async {
    if (nomeDigitado.text.trim().isEmpty || precoDigitado.text.trim().isEmpty) return;

    List<String> dados = produtoAntigo.split("|");
    dynamic id = dados.length > 4 ? dados[4] : "";

    final double precoVal = double.tryParse(precoDigitado.text.trim()) ?? 0.0;
    final String imagemVal = urlDigitado.text.trim().isNotEmpty
        ? urlDigitado.text.trim()
        : "assets/items/bolo_morango.png";

    Map<String, dynamic> produtoEditado = {
      "nome": nomeDigitado.text.trim(),
      "preco": precoVal,
      "categoria": categoriaSelecionada,
      "imagem": imagemVal,
    };

    if (id.toString().isNotEmpty && !id.toString().startsWith("temp_")) {
      await ApiService.atualizarProduto(id, produtoEditado);
    }

    SharedPreferences banco = await SharedPreferences.getInstance();
    List<String> produtosBanco = banco.getStringList("produtos") ?? [];

    String produtoNovoFormatado =
        "${nomeDigitado.text.trim()}|$precoVal|$categoriaSelecionada|$imagemVal|$id";

    int index = produtosBanco.indexOf(produtoAntigo);
    if (index != -1) {
      produtosBanco[index] = produtoNovoFormatado;
      await banco.setStringList("produtos", produtosBanco);
    }

    nomeDigitado.clear();
    precoDigitado.clear();
    urlDigitado.clear();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comércio atualizado com sucesso! ✏️💕")),
      );
    }

    carregarProdutos();
  }

  // =========================================================================
  // 4. DELETE: Elimina da API e remove do Banco Local
  // =========================================================================
  void deletarProduto(String produtoFormatado) async {
    List<String> dados = produtoFormatado.split("|");
    dynamic id = dados.length > 4 ? dados[4] : "";

    if (id.toString().isNotEmpty && !id.toString().startsWith("temp_")) {
      await ApiService.deletarProduto(id);
    }

    SharedPreferences banco = await SharedPreferences.getInstance();
    List<String> produtosBanco = banco.getStringList("produtos") ?? [];
    produtosBanco.remove(produtoFormatado);
    await banco.setStringList("produtos", produtosBanco);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comércio eliminado com sucesso!")),
      );
    }

    carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF529A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text("Cadastrar Loja", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _abrirModalCadastro(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderRibbon(
                icon: Icons.arrow_back_rounded,
                titulo: "Comércios da Cidade",
                subtitulo: "Persistência híbrida ativa: itens mantidos ao sair! 💕",
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
                child: carregando
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
                    : mostrarProdutos.isEmpty
                        ? const Center(
                            child: Text(
                              "Nenhum comércio cadastrado.",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          )
                        : GridView(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            children: [
                              for (String produto in mostrarProdutos) ...[
                                _buildCardComercio(produto)
                              ]
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardComercio(String produtoFormatado) {
    List<String> dados = produtoFormatado.split("|");
    String nome = dados.isNotEmpty ? dados[0] : "Sem Nome";
    String preco = dados.length > 1 ? dados[1] : "0.00";
    String categoria = dados.length > 2 ? dados[2] : "Geral";
    String imagem = dados.length > 3 ? dados[3] : "assets/items/bolo_morango.png";

    bool isNetwork = imagem.startsWith("http");

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _abrirModalDetalhesComercio(produtoFormatado),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isNetwork
                      ? Image.network(
                          imagem,
                          height: 75,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset('assets/items/bolo_morango.png', height: 75),
                        )
                      : Image.asset(
                          imagem,
                          height: 75,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.storefront, size: 50, color: Color(0xFFFF69B4)),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 2),
                Text(
                  "$preco moedas • $categoria",
                  style: const TextStyle(fontSize: 10, color: Color(0xFFFF529A), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF529A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _abrirModalEdicao(produtoFormatado),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: const Text("Editar", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => deletarProduto(produtoFormatado),
                    icon: const Icon(Icons.delete_rounded, size: 14),
                    label: const Text("Deletar", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirModalDetalhesComercio(String produtoFormatado) {
    List<String> dados = produtoFormatado.split("|");
    String nome = dados.isNotEmpty ? dados[0] : "Sem Nome";
    String preco = dados.length > 1 ? dados[1] : "0.00";
    String categoria = dados.length > 2 ? dados[2] : "Geral";
    String imagem = dados.length > 3 ? dados[3] : "assets/items/bolo_morango.png";

    bool isNetwork = imagem.startsWith("http");

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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: isNetwork
                    ? Image.network(
                        imagem,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image.asset('assets/items/bolo_morango.png', height: 140),
                      )
                    : Image.asset(
                        imagem,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.storefront, size: 70, color: Color(0xFFFF69B4)),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                nome,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 6),
              Text(
                "Categoria: $categoria",
                style: const TextStyle(fontSize: 13, color: Color(0xFFFF529A), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC0CB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "$preco Moedas",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFF529A)),
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
                    SharedPreferences banco = await SharedPreferences.getInstance();
                    await banco.setBool('acao_comercio', true);
                    int xp = banco.getInt('user_xp') ?? 145;
                    int moedas = banco.getInt('user_moedas') ?? 120;
                    await banco.setInt('user_xp', xp + 20);
                    await banco.setInt('user_moedas', moedas + 20);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comércio "$nome" apoiado! 💕 (+20 XP / +20 Moedas)')),
                      );
                    }
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 20),
                  label: const Text("Apoiar Este Comércio (+20 XP)", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirModalCadastro() {
    nomeDigitado.clear();
    precoDigitado.clear();
    urlDigitado.clear();
    categoriaSelecionada = "Docerias";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Cadastrar Loja 🛍️",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomeDigitado,
                    decoration: InputDecoration(
                      labelText: "Nome do Produto/Loja",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: precoDigitado,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Preço (Moedas)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlDigitado,
                    decoration: InputDecoration(
                      labelText: "URL da Imagem ou Caminho Asset",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    decoration: InputDecoration(
                      labelText: "Categoria",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: ["Docerias", "Acessórios", "Papelaria"].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => categoriaSelecionada = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF529A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: salvarProduto,
                      child: const Text("Salvar Comércio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _abrirModalEdicao(String produtoFormatado) {
    List<String> dados = produtoFormatado.split("|");
    nomeDigitado.text = dados.isNotEmpty ? dados[0] : "";
    precoDigitado.text = dados.length > 1 ? dados[1] : "";
    categoriaSelecionada = (dados.length > 2 && ["Docerias", "Acessórios", "Papelaria"].contains(dados[2]))
        ? dados[2]
        : "Docerias";
    urlDigitado.text = dados.length > 3 ? dados[3] : "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Editar Comércio ✏️",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nomeDigitado,
                    decoration: InputDecoration(
                      labelText: "Nome do Produto/Loja",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: precoDigitado,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Preço (Moedas)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlDigitado,
                    decoration: InputDecoration(
                      labelText: "URL da Imagem ou Caminho Asset",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    decoration: InputDecoration(
                      labelText: "Categoria",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: ["Docerias", "Acessórios", "Papelaria"].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => categoriaSelecionada = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF529A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => editarProduto(produtoFormatado),
                      child: const Text("Atualizar Comércio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
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