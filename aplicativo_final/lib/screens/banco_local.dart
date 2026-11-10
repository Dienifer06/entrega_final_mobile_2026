import 'package:shared_preferences/shared_preferences.dart';

class BancoLocal {
  /// Procura a lista de itens guardados para uma chave específica
  static Future<List<String>> carregar(String chave) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(chave) ?? [];
  }

  /// Adiciona um novo registo formatado sem duplicados
  static Future<void> salvar(String chave, String itemFormatado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = prefs.getStringList(chave) ?? [];
    if (!lista.contains(itemFormatado)) {
      lista.add(itemFormatado);
      await prefs.setStringList(chave, lista);
    }
  }

  /// Remove um registo exato da chave especificada
  static Future<void> deletar(String chave, String itemFormatado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> lista = prefs.getStringList(chave) ?? [];
    lista.remove(itemFormatado);
    await prefs.setStringList(chave, lista);
  }

  /// Guarda a lista completa substituindo o conteúdo existente
  static Future<void> salvarLista(String chave, List<String> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(chave, lista);
  }
}