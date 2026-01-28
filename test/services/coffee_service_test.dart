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

    test('should have caffeine values for all coffee types', () {
      // Vérifier que tous les types de café ont une valeur de caféine
      for (final type in CoffeeType.values) {
        expect(type.caffeinemg, greaterThan(0));
      }
    });
  });
}
