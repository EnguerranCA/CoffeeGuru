import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/coffee_log.dart';
// ignore: unused_import
import 'package:flutter_application_1/services/coffee_service.dart';

// Ces tests nécessitent Supabase initialisé - skip pour CI
void main() {
  group('CoffeeService Basic Operations', () {
    test('should add and remove coffee logs', skip: 'Requires Supabase', () {
      // Test skipped - requires Supabase
    });

    test('should sort logs by timestamp', skip: 'Requires Supabase', () {
      // Test skipped - requires Supabase
    });
  });

  group('CoffeeService Statistics', () {
    test('should count today\'s coffee logs correctly', skip: 'Requires Supabase', () {
      // Test skipped - requires Supabase
    });

    test('should group logs by date', skip: 'Requires Supabase', () {
      // Test skipped - requires Supabase
    });
  });

  // Tests unitaires qui fonctionnent sans Supabase
  group('CoffeeLog Model Unit Tests', () {
    test('should create CoffeeLog with required fields', () {
      final log = CoffeeLog(
        id: '1',
        userId: 'test-user',
        type: CoffeeType.espresso,
        locationType: CoffeeLocation.home,
        timestamp: DateTime.now(),
      );

      expect(log.id, '1');
      expect(log.userId, 'test-user');
      expect(log.type, CoffeeType.espresso);
      expect(log.locationType, CoffeeLocation.home);
    });

    test('should get location display name', () {
      final log = CoffeeLog(
        id: '1',
        userId: 'test-user',
        type: CoffeeType.espresso,
        locationType: CoffeeLocation.home,
        timestamp: DateTime.now(),
      );

      expect(log.getLocationDisplayName(), 'Chez moi');
      expect(log.getLocationEmoji(), '🏠');
    });

    test('should calculate today\'s total caffeine correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      
      // Espresso: 63mg + Americano: 94mg + Cold Brew: 200mg = 357mg
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: today,
      ));
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '2',
        type: CoffeeType.americano,
        location: CoffeeLocation.work,
        timestamp: today,
      ));
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '3',
        type: CoffeeType.coldBrew,
        location: CoffeeLocation.cafe,
        timestamp: today,
      ));

      expect(coffeeService.getTodayCaffeine(), 357);
    });

    test('should calculate caffeine percentage correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      
      // 200mg / 400mg = 50%
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.coldBrew,
        location: CoffeeLocation.home,
        timestamp: today,
      ));

      expect(coffeeService.getCaffeinePercentage(), 50.0);
    });
  });
}
