import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/coffee_log.dart';
import '../services/coffee_service.dart';
import '../widgets/add_coffee_dialog.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final CoffeeService _coffeeService = CoffeeService();

  Future<void> _showAddCoffeeDialog() async {
    final result = await showDialog<CoffeeLog>(
      context: context,
      builder: (context) => const AddCoffeeDialog(),
    );

    if (result != null) {
      setState(() {
        _coffeeService.addCoffeeLog(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.type.emoji} ${result.type.displayName} ajouté !'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteCoffeeLog(String id) {
    setState(() {
      _coffeeService.removeCoffeeLog(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consommation supprimée'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Row(
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
