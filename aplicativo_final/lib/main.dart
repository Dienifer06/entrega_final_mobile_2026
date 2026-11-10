import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/comercios_screen.dart';
import 'screens/eventos_screen.dart';
import 'screens/servicos_screen.dart';
import 'screens/oportunidades_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/livros_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MinhaCidadeDigitalApp());
}

class MinhaCidadeDigitalApp extends StatelessWidget {
  const MinhaCidadeDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Kitty - Minha Cidade Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF529A),
          primary: const Color(0xFFFF529A),
          secondary: const Color(0xFFFFB6C1),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/', // 
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/mapa': (context) => const MapaScreen(),
        '/comercios': (context) => const ComerciosScreen(),
        '/eventos': (context) => const EventosScreen(),
        '/servicos': (context) => const ServicosScreen(),
        '/oportunidades': (context) => const OportunidadesScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/livros': (context) => const LivrosScreen(),
      },
    );
  }
}