import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'pages/tracker_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/profile_page.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la connexion à Supabase
  try {
    await DatabaseService().initialize();
    print('✅ Supabase initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Supabase: $e');
    print('⚠️ L\'application va démarrer mais les fonctionnalités de base de données ne seront pas disponibles.');
    print('⚠️ Veuillez vérifier votre fichier .env et les variables SUPABASE_URL et SUPABASE_ANON_KEY');
  }

  // Initialiser l'authentification
  try {
    await AuthService().initialize();
    print('✅ Authentification initialisée');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de l\'authentification: $e');
  }

  runApp(const CoffeeGuruApp());
}

class CoffeeGuruApp extends StatelessWidget {
  const CoffeeGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Guru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4423), // Marron café
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5E6D3), // Beige
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5E6D3), // Beige
          foregroundColor: Color(0xFF6B4423), // Marron
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFEDD5B8), // Beige plus foncé
          indicatorColor: const Color(0xFF6B4423).withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: Color(0xFF6B4423),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 12,
            );
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6B4423),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapPage(),
    const TrackerPage(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Classement',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
