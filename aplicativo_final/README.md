# aplicativo_final

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Comparativo de APIs: Flutter (Dart) vs. Python (Django)
Este documento apresenta uma análise comparativa sobre o papel e o funcionamento de APIs no ecossistema Flutter (desenvolvimento cliente/mobile) e no Python com Django (desenvolvimento servidor/backend).

1. Visão Geral das Responsabilidades
Critério	Python com Django (Backend)	Flutter (Frontend / Mobile)
Papel Principal	Provedor de API / Servidor REST	Consumidor de API / Cliente
Linguagem	Python	Dart
Função no Fluxo	Processa regras de negócio, acede ao banco de dados e expõe endpoints JSON.	Faz requisições HTTP, consome os dados em JSON e constrói a interface gráfica (UI).
Persistência de Dados	Banco de dados relacional (PostgreSQL, SQLite, MySQL) via ORM.	Armazenamento de sessão e cache local (SharedPreferences).
Segurança & CORS	Configura cabeçalhos de permissão (django-cors-headers), tokens e autenticação.	Envia cabeçalhos adequados (Content-Type: application/json) e tokens nas requisições.
2. Diferenças Estruturais de Arquitetura
🐍 Python com Django (Django REST Framework)
No backend Django, a API é construída em camadas estruturadas:

Models (models.py): Define a estrutura das tabelas no banco de dados.

Serializers (serializers.py): Converte objetos Python/modelos em dicionários e sequências de texto JSON (e vice-versa).

Views (views.py / viewsets.py): Recebe a requisição do cliente, executa a lógica de negócio e devolve uma resposta HTTP (200 OK, 201 Created, 400 Bad Request, 404 Not Found).

URLs (urls.py): Mapeia as rotas de acesso (ex: /api/produtos/).

💙 Flutter (Dart)
No cliente Flutter, a API é consumida através de chamadas assíncronas e gestão de estado:

Camada de Serviço (api_service.dart): Utiliza o pacote http para disparar métodos assíncronos (Future) como http.get, http.post, http.put e http.delete.

Decodificação de JSON (jsonDecode): Converte a resposta em texto vinda do servidor em estruturas de dados nativas (List, Map).

Persistência Híbrida/Local: Trata exceções e faz fallback guardando dados no SharedPreferences (ex: linhas formatadas por delimitador |).

Interface (StatefulWidget): Atualiza os componentes visuais e a árvore de widgets através de métodos de estado como setState() ou FutureBuilder.

3. Comparativo Prático de Código
Criar/Salvar um Produto (CRUD - POST)
No Backend (Python / Django REST Framework)
Python
# views.py (Django)
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Produto
from .serializers import ProdutoSerializer

@api_view(['POST'])
def criar_produto(request):
    serializer = ProdutoSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
No Frontend (Flutter / Dart)
Dart
// api_service.dart (Flutter)
import 'dart0:convert';
import 'package:http/http.dart' as http;

static Future<bool> criarProduto(Map<String, dynamic> produto) async {
  try {
    final response = await http.post(
      Uri.parse('https://api-exemplo.com/produtos'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(produto),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
4. Resumo de Integração
Django cria, valida, guarda os dados no banco central e expõe o JSON.

Flutter consome o JSON do Django via requisições HTTP, exibe as informações no ecrã com componentes Kawaii e garante que o utilizador consiga operar offline através do armazenamento local no dispositivo.