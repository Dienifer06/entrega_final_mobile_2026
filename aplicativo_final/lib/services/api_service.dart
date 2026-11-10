import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Endereço base da API no Render
  static const String baseUrl = 'https://mercadinho-api-0.onrender.com';

  // ==========================================
  // 1. CRUD DE PRODUTOS / COMÉRCIOS (RENDER)
  // ==========================================

  /// GET: Procura a lista atualizada de produtos/comércios na API
  static Future<List<dynamic>> getProdutos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produtos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Erro ao carregar produtos da API: $e");
    }
    return [];
  }

  /// POST: Envia um novo produto para a API do Render (Espera 201)
  static Future<bool> criarProduto(Map<String, dynamic> produto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/produtos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(produto),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro no POST do produto: $e");
      return false;
    }
  }

  /// PUT: Atualiza as informações de um produto existente pelo ID (Espera 200)
  static Future<bool> atualizarProduto(dynamic id, Map<String, dynamic> produto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/produtos/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(produto),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro no PUT do produto: $e");
      return false;
    }
  }

  /// DELETE: Remove permanentemente um produto pelo ID na API (Espera 200)
  static Future<bool> deletarProduto(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/produtos/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Erro no DELETE do produto: $e");
      return false;
    }
  }

  // ==========================================
  // 2. CONSULTAS DOS OUTROS MÓDULOS DA CIDADE
  // ==========================================

  /// GET: Procura a agenda de eventos na API
  static Future<List<dynamic>> getEventos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/eventos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Erro ao carregar eventos da API: $e");
    }
    return [
      {
        "id": 1,
        "nome": "Festival Kawaii de Primavera",
        "data": "Sáb - Dom",
        "local": "Parque da Cidade",
        "descricao": "Espetáculos ao vivo, barracas de doces e feira de artesanato fofo com a Hello Kitty e amigos!"
      },
      {
        "id": 2,
        "nome": "Oficina de Desenho Hello Kitty",
        "data": "Quarta-feira, 15h",
        "local": "Centro Cultural",
        "descricao": "Aprende a desenhar personagens kawaii e ganha adesivos e recompensas exclusivas."
      }
    ];
  }

  /// GET: Procura os serviços públicos na API
  static Future<List<dynamic>> getServicos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/servicos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Erro ao carregar serviços da API: $e");
    }
    return [
      {
        "id": 1,
        "titulo": "Posto de Saúde Central",
        "categoria": "Saúde",
        "horario": "Seg. a Sex. das 07h às 17h",
        "endereco": "Rua das Flores, 123",
        "telefone": "(11) 4002-8922",
        "descricao": "Atendimento médico geral, vacinação infantil, consultas e cuidados de saúde para toda a comunidade."
      }
    ];
  }

  /// GET: Procura vagas de oportunidade/estágio na API
  static Future<List<dynamic>> getOportunidades() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/oportunidades'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Erro ao carregar oportunidades da API: $e");
    }
    return [
      {
        "id": 1,
        "titulo": "Assistente Administrativo",
        "empresa": "TechDream",
        "local": "Centro",
        "nivel": "Ensino Médio",
        "descricao": "Apoio na organização de documentos digitais e atendimento simpático aos cidadãos."
      }
    ];
  }

  // ==========================================
  // 3. INTEGRAÇÃO EXTERNA (OPEN LIBRARY API)
  // ==========================================

  /// GET: Procura acervo de livros na Open Library pública
  static Future<List<dynamic>> buscarLivrosOpenLibrary(String termo) async {
    try {
      final query = Uri.encodeComponent(termo.trim());
      final response = await http.get(
        Uri.parse('https://openlibrary.org/search.json?q=$query&limit=10'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['docs'] ?? [];
      }
    } catch (e) {
      debugPrint("Erro ao consultar Open Library: $e");
    }
    return [];
  }
}