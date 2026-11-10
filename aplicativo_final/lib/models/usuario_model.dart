class UsuarioModel {
  final String nome;
  int xp;
  int moedas;
  int conquistasConcluidas;
  final int totalConquistas;

  UsuarioModel({
    required this.nome,
    this.xp = 120,
    this.moedas = 250,
    this.conquistasConcluidas = 0,
    this.totalConquistas = 4,
  });

  void adicionarXp(int quantidade) {
    xp += quantidade;
  }

  void adicionarMoedas(int quantidade) {
    moedas += quantidade;
  }
}
