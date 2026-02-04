import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/coffee_log.dart';
import '../services/coffee_service.dart';
import '../services/badge_service.dart';
import '../widgets/add_coffee_dialog.dart';
import '../widgets/caffeine_progress_bar.dart';
import '../widgets/badge_notification.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final CoffeeService _coffeeService = CoffeeService();
  final BadgeService _badgeService = BadgeService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Initialiser le formatage de date pour le français
    await initializeDateFormatting('fr_FR', null);
    await _loadLogs();
  }

  Future<void> _loadLogs() async {
    await _coffeeService.getCoffeeLogs();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNewBadges() async {
    final newBadges = await _badgeService.checkNewlyUnlockedBadges();
    
    if (mounted && newBadges.isNotEmpty) {
      // Afficher une notification pour chaque nouveau badge
      for (var badge in newBadges) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          BadgeUnlockedNotification.show(context, badge);
        }
      }
    }
  }

  Future<void> _showAddCoffeeDialog() async {
    final result = await showDialog<CoffeeLog>(
      context: context,
      builder: (context) => const AddCoffeeDialog(),
    );

    if (result != null) {
      final addedLog = await _coffeeService.addCoffeeLog(result);
      
      if (addedLog != null && mounted) {
        setState(() {});
        
        // Vérifier les nouveaux badges débloqués
        _checkNewBadges();
        
        // Vérifier si la limite de caféine est atteinte
        final todayCaffeine = _coffeeService.getTodayCaffeine();
        if (todayCaffeine >= 400) {
          _showCaffeineLimitWarning(todayCaffeine);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.type.emoji} ${result.type.displayName} ajouté !'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout du café'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showCaffeineLimitWarning(int caffeine) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5E6D3),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 60,
        ),
        title: const Text(
          '⚠️ Limite de caféine atteinte',
          style: TextStyle(
            color: Color(0xFF6B4423),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vous avez consommé $caffeine mg de caféine aujourd\'hui.',
              style: const TextStyle(
                color: Color(0xFF6B4423),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: const Text(
                '⚕️ La limite recommandée est de 400 mg par jour.\n\nUne consommation excessive peut causer de l\'anxiété, des troubles du sommeil et des palpitations.',
                style: TextStyle(
                  color: Color(0xFF6B4423),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'J\'ai compris',
              style: TextStyle(
                color: Color(0xFF6B4423),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCoffeeLog(String id) async {
    final success = await _coffeeService.removeCoffeeLog(id);

    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consommation supprimée'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Coffee Tracker'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final todayCount = _coffeeService.getTodayCount();
    final coffeeLogs = _coffeeService.coffeeLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Tracker'),
        centerTitle: true,
      ),
      body: coffeeLogs.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildTodayStats(todayCount),
                Expanded(
                  child: _buildCoffeeList(coffeeLogs),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCoffeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un café'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_cafe_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun café enregistré',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à suivre votre consommation\nen ajoutant votre premier café !',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(int todayCount) {
    final todayCaffeine = _coffeeService.getTodayCaffeine();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compteur de cafés
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_cafe,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aujourd'hui",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  Text(
                    '$todayCount café${todayCount > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // Barre de progression de caféine
          CaffeineProgressBar(
            currentCaffeine: todayCaffeine,
            dailyLimit: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeList(List<CoffeeLog> logs) {
    final logsByDate = _coffeeService.getLogsByDate();
    final sortedDates = logsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final logsForDate = logsByDate[date]!;
        final isToday = _isToday(date);
        final isYesterday = _isYesterday(date);

        String dateLabel;
        if (isToday) {
          dateLabel = "Aujourd'hui";
        } else if (isYesterday) {
          dateLabel = 'Hier';
        } else {
          dateLabel = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ...logsForDate.map((log) => _buildCoffeeLogCard(log)),
          ],
        );
      },
    );
  }

  Widget _buildCoffeeLogCard(CoffeeLog log) {
    final timeFormat = DateFormat('HH:mm');
    
    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer'),
            content: const Text('Voulez-vous supprimer cette consommation ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteCoffeeLog(log.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              log.type.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          title: Text(
            log.type.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${log.location.emoji} ${log.location.displayName}',
          ),
          trailing: Text(
            timeFormat.format(log.timestamp),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
