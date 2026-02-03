import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/coffee_service.dart';
import '../services/badge_service.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/badge_display.dart';
import '../models/badge.dart' as badge_model;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final CoffeeService _coffeeService = CoffeeService();
  final BadgeService _badgeService = BadgeService();
  
  List<badge_model.Badge> _badges = [];
  bool _loadingBadges = true;
  bool _hasShownAuthDialog = false; // Pour éviter de réafficher le dialog

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    if (mounted) {
      setState(() => _loadingBadges = true);
    }
    
    final badges = await _badgeService.getAllBadges();
    
    if (mounted) {
      setState(() {
        _badges = badges;
        _loadingBadges = false;
      });
    }
  }

  void _checkAuth() {
    if (_authService.isGuest && !_hasShownAuthDialog) {
      // Afficher le dialog de connexion après le premier build
      _hasShownAuthDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthDialog();
      });
    }
  }

  Future<void> _showAuthDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AuthDialog(isSignup: false),
    );

    if (result == true && mounted) {
      // Connexion réussie, rafraîchir les données
      await _coffeeService.refreshLogs();
      await _loadBadges();
      setState(() {});
    }
    // Si annulé (result == false ou null), on reste sur la page
    // Le flag _hasShownAuthDialog empêchera de réafficher le dialog
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      _coffeeService.clearCache();
      setState(() {});
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Connectez-vous pour accéder à votre profil',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _hasShownAuthDialog = false);
                  _showAuthDialog();
                },
                icon: const Icon(Icons.login),
                label: const Text('Se connecter'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4423),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = _authService.currentUser!;
    final totalCoffees = _coffeeService.coffeeLogs.length;
    final todayCount = _coffeeService.getTodayCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar et nom
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF6B4423).withOpacity(0.2),
              child: Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4423),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Membre depuis ${_formatDate(user.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Statistiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.local_cafe,
                  label: 'Total cafés',
                  value: totalCoffees.toString(),
                ),
                _buildStatCard(
                  icon: Icons.today,
                  label: 'Aujourd\'hui',
                  value: todayCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section badges
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Color(0xFF6B4423)),
                            const SizedBox(width: 8),
                            Text(
                              'Badges',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          '${_badges.where((b) => b.isUnlocked).length}/${_badges.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loadingBadges)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_badges.isEmpty)
                      Center(
                        child: Text(
                          'Aucun badge disponible',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    else
                      BadgeGrid(badges: _badges),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF6B4423)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4423),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
