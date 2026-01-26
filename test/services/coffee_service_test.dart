import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/coffee_log.dart';
import 'package:flutter_application_1/services/coffee_service.dart';

void main() {
  late CoffeeService coffeeService;

  setUp(() {
    coffeeService = CoffeeService();
    // Nettoyer toutes les données avant chaque test
    for (var log in coffeeService.coffeeLogs.toList()) {
      coffeeService.removeCoffeeLog(log.id);
    }
  });

  group('CoffeeService Basic Operations', () {
    test('should add and remove coffee logs', () {
      final log = CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: DateTime.now(),
      );

      coffeeService.addCoffeeLog(log);
      expect(coffeeService.coffeeLogs.length, 1);

      coffeeService.removeCoffeeLog('1');
      expect(coffeeService.coffeeLogs.length, 0);
    });

    test('should sort logs by timestamp (most recent first)', () {
      final old = CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: DateTime(2026, 1, 26, 10, 0),
      );
      final recent = CoffeeLog(
        id: '2',
        type: CoffeeType.latte,
        location: CoffeeLocation.work,
        timestamp: DateTime(2026, 1, 26, 14, 0),
      );

      coffeeService.addCoffeeLog(old);
      coffeeService.addCoffeeLog(recent);

      expect(coffeeService.coffeeLogs.first.id, '2');
    });
  });

  group('CoffeeService Statistics', () {
    test('should count today\'s coffee logs correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 0);

      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: today,
      ));
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '2',
        type: CoffeeType.latte,
        location: CoffeeLocation.work,
        timestamp: yesterday,
      ));

      expect(coffeeService.getTodayCount(), 1);
      expect(coffeeService.getTodayLogs().length, 1);
    });

    test('should group logs by date', () {
      final date1 = DateTime(2026, 1, 26, 10, 0);
      final date2 = DateTime(2026, 1, 25, 10, 0);

      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: date1,
      ));
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '2',
        type: CoffeeType.latte,
        location: CoffeeLocation.work,
        timestamp: date2,
      ));

      final logsByDate = coffeeService.getLogsByDate();
      expect(logsByDate.length, 2);
    });
  });
}
