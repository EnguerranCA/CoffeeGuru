import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import '../widgets/auth_dialog.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  
  late TabController _tabController;
  bool _isLoading = true;
  
  List<LeaderboardEntry> _consumptionLeaderboard = [];
  List<LeaderboardEntry> _placesLeaderboard = [];
  List<LeaderboardEntry> _typesLeaderboard = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAuth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAuth() {
    if (_authService.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthDialog();
      });
    } else {
      _loadLeaderboards();
    }
  }

  Future<void> _showAuthDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AuthDialog(isSignup: false),
    );

    if (result == true && mounted) {
      setState(() {});
      _loadLeaderboards();
    } else if (!(result ?? false) && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadLeaderboards() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _leaderboardService.getTotalConsumptionLeaderboard(),
        _leaderboardService.getPlacesVisitedLeaderboard(),
        _leaderboardService.getCoffeeTypesLeaderboard(),
      ]);
      
      if (mounted) {
        setState(() {
          _consumptionLeaderboard = results[0];
          _placesLeaderboard = results[1];
          _typesLeaderboard = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement leaderboards: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Classement'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6B4423),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6B4423),
          tabs: const [
            Tab(
              icon: Icon(Icons.local_cafe),
              text: 'Cafés bus',
            ),
            Tab(
              icon: Icon(Icons.location_on),
              text: 'Lieux visités',
            ),
            Tab(
              icon: Icon(Icons.coffee),
              text: 'Recettes',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(
                  _consumptionLeaderboard,
                  'cafés bus',
                  Icons.local_cafe,
                ),
                _buildLeaderboardList(
                  _placesLeaderboard,
                  'lieux visités',
                  Icons.location_on,
                ),
                _buildLeaderboardList(
                  _typesLeaderboard,
                  'recettes goûtées',
                  Icons.coffee,
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboardList(
    List<LeaderboardEntry> entries,
    String unit,
    IconData icon,
  ) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez à logger vos cafés !',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isCurrentUser = entry.userId == _authService.currentUserId;
          
          return _buildLeaderboardCard(
            entry: entry,
            unit: unit,
            icon: icon,
            isCurrentUser: isCurrentUser,
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required LeaderboardEntry entry,
    required String unit,
    required IconData icon,
    required bool isCurrentUser,
  }) {
    Color? medalColor;
    IconData? medalIcon;
    
    if (entry.rank == 1) {
      medalColor = Colors.amber;
      medalIcon = Icons.emoji_events;
    } else if (entry.rank == 2) {
      medalColor = Colors.grey[400];
      medalIcon = Icons.emoji_events;
    } else if (entry.rank == 3) {
      medalColor = Colors.brown[300];
      medalIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF6B4423).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
              ? const Color(0xFF6B4423)
              : Colors.grey[300]!,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rang
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: medalColor ?? Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: medalIcon != null
                    ? Icon(medalIcon, color: Colors.white, size: 24)
                    : Text(
                        '#${entry.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: medalColor != null ? Colors.white : Colors.grey[700],
                        ),
                      ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentUser ? const Color(0xFF6B4423) : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4423),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Vous',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6B4423), size: 20),
            const SizedBox(width: 8),
            Text(
              '${entry.value}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4423),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

