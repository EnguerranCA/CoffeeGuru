import '../models/coffee_log.dart';

class CoffeeService {
  // Singleton pattern pour partager la même instance
  static final CoffeeService _instance = CoffeeService._internal();
  factory CoffeeService() => _instance;
  CoffeeService._internal();

  final List<CoffeeLog> _coffeeLogs = [];

  List<CoffeeLog> get coffeeLogs => List.unmodifiable(_coffeeLogs);

  // Ajouter une nouvelle consommation
  void addCoffeeLog(CoffeeLog log) {
    _coffeeLogs.add(log);
    // Trier par date décroissante (plus récent en premier)
    _coffeeLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Supprimer une consommation
  void removeCoffeeLog(String id) {
    _coffeeLogs.removeWhere((log) => log.id == id);
  }

  // Obtenir les consommations du jour
  List<CoffeeLog> getTodayLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _coffeeLogs.where((log) {
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      return logDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Compter les cafés du jour
  int getTodayCount() {
    return getTodayLogs().length;
  }

  // Calculer la caféine totale du jour (en mg)
  int getTodayCaffeine() {
    return getTodayLogs().fold(0, (sum, log) => sum + log.type.caffeinemg);
  }

  // Calculer le pourcentage de caféine par rapport à la limite (400mg)
  double getCaffeinePercentage({int dailyLimit = 400}) {
    final caffeine = getTodayCaffeine();
    return (caffeine / dailyLimit * 100).clamp(0, 200); // Max 200% pour affichage
  }

  // Obtenir les consommations par date
  Map<DateTime, List<CoffeeLog>> getLogsByDate() {
    final Map<DateTime, List<CoffeeLog>> logsByDate = {};
    for (var log in _coffeeLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (!logsByDate.containsKey(date)) {
        logsByDate[date] = [];
      }
      logsByDate[date]!.add(log);
    }
    return logsByDate;
  }
}
