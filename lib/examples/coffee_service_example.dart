import 'package:flutter/material.dart';
import '../models/coffee_log.dart';
import '../services/coffee_service.dart';

/// Widget pour tester et démontrer l'utilisation du CoffeeService
/// Ce widget n'est pas utilisé dans l'app principale mais sert d'exemple
class CoffeeServiceExample extends StatefulWidget {
  const CoffeeServiceExample({super.key});

  @override
  State<CoffeeServiceExample> createState() => _CoffeeServiceExampleState();
}

class _CoffeeServiceExampleState extends State<CoffeeServiceExample> {
  final CoffeeService _coffeeService = CoffeeService();

  @override
  void initState() {
    super.initState();
    _addExampleData();
  }

  /// Ajoute des données d'exemple pour tester
  void _addExampleData() {
    // Café d'aujourd'hui
    _coffeeService.addCoffeeLog(
      CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );

    _coffeeService.addCoffeeLog(
      CoffeeLog(
        id: '2',
        type: CoffeeType.cappuccino,
        location: CoffeeLocation.work,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    );

    // Cafés d'hier
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _coffeeService.addCoffeeLog(
      CoffeeLog(
        id: '3',
        type: CoffeeType.latte,
        location: CoffeeLocation.cafe,
        timestamp: yesterday.subtract(const Duration(hours: 3)),
      ),
    );

    _coffeeService.addCoffeeLog(
      CoffeeLog(
        id: '4',
        type: CoffeeType.americano,
        location: CoffeeLocation.work,
        timestamp: yesterday.subtract(const Duration(hours: 8)),
      ),
    );

    // Cafés d'il y a 3 jours
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    _coffeeService.addCoffeeLog(
      CoffeeLog(
        id: '5',
        type: CoffeeType.mocha,
        location: CoffeeLocation.friend,
        timestamp: threeDaysAgo.subtract(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = _coffeeService.getTodayCount();
    final totalCount = _coffeeService.coffeeLogs.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Service Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Cafés aujourd\'hui : $todayCount'),
                    Text('Total de cafés : $totalCount'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Liste des consommations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _coffeeService.coffeeLogs.length,
                itemBuilder: (context, index) {
                  final log = _coffeeService.coffeeLogs[index];
                  return ListTile(
                    leading: Text(log.type.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(log.type.displayName),
                    subtitle: Text(
                      '${log.location.displayName} - ${log.timestamp.toString()}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
