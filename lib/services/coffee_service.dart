import '../models/coffee_log.dart';
import 'database_service.dart';
import 'auth_service.dart';

class CoffeeService {
  // Singleton pattern pour partager la même instance
  static final CoffeeService _instance = CoffeeService._internal();
  factory CoffeeService() => _instance;
  CoffeeService._internal();

  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  // Cache local des logs
  List<CoffeeLog> _cachedLogs = [];

  /// Récupère tous les logs de l'utilisateur courant depuis Supabase
  Future<List<CoffeeLog>> getCoffeeLogs() async {
    try {
      final userId = _auth.currentUserId;
      final data = await _db.getCoffeeLogsByUser(userId);
      _cachedLogs = data.map((json) => CoffeeLog.fromJson(json)).toList();
      // Trier par date décroissante
      _cachedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return _cachedLogs;
    } catch (e) {
      print('❌ Erreur dans CoffeeService.getCoffeeLogs: $e');
      return [];
    }
  }

  /// Getter pour rétrocompatibilité avec l'ancien code
  List<CoffeeLog> get coffeeLogs => _cachedLogs;

  // Ajouter une nouvelle consommation (dans Supabase)
  Future<CoffeeLog?> addCoffeeLog(CoffeeLog log) async {
    try {
      final insertedData = await _db.insert(
        DatabaseService.coffeeLogsTable,
        log.toInsertJson(),
      );

      if (insertedData == null) return null;

      final newLog = CoffeeLog.fromJson(insertedData);
      _cachedLogs.add(newLog);
      // Trier par date décroissante
      _cachedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return newLog;
    } catch (e) {
      print('❌ Erreur dans CoffeeService.addCoffeeLog: $e');
      return null;
    }
  }

  // Supprimer une consommation (de Supabase)
  Future<bool> removeCoffeeLog(String id) async {
    try {
      await _db.delete(DatabaseService.coffeeLogsTable, id);
      _cachedLogs.removeWhere((log) => log.id == id);
      return true;
    } catch (e) {
      print('❌ Erreur dans CoffeeService.removeCoffeeLog: $e');
      return false;
    }
  }

  // Obtenir les consommations du jour
  List<CoffeeLog> getTodayLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _cachedLogs.where((log) {
      final logDate =
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
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
    for (var log in _cachedLogs) {
      final date =
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (!logsByDate.containsKey(date)) {
        logsByDate[date] = [];
      }
      logsByDate[date]!.add(log);
    }
    return logsByDate;
  }

  // Rafraîchir les logs depuis la base de données
  Future<void> refreshLogs() async {
    await getCoffeeLogs();
  }

  // Nettoyer le cache
  void clearCache() {
    _cachedLogs.clear();
  }
}
