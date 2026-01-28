import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/cafe_place.dart';
import 'package:flutter_application_1/models/coffee_log.dart';
import 'package:flutter_application_1/services/cafe_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  late CafeService cafeService;

  setUp(() {
    cafeService = CafeService();
    cafeService.clearCache();
  });

  group('CafeService Singleton', () {
    test('should return same instance', () {
      final service1 = CafeService();
      final service2 = CafeService();

      expect(service1, same(service2));
    });
  });

  group('CafeService Filter Operations (with local data)', () {
    // Ces tests utilisent des données locales pour tester la logique de filtrage
    // sans dépendre de Supabase
    final testCafes = [
      Cafe(
        id: '1',
        name: 'Café Test 1',
        address: '1 Rue Test',
        location: const LatLng(48.8566, 2.3522),
        type: CafeType.cafe,
        availableCoffeeTypes: [CoffeeType.espresso, CoffeeType.latte],
      ),
      Cafe(
        id: '2',
        name: 'Bar Test',
        address: '2 Rue Test',
        location: const LatLng(48.8567, 2.3523),
        type: CafeType.bar,
        availableCoffeeTypes: [CoffeeType.americano],
      ),
      Cafe(
        id: '3',
        name: 'Restaurant Test',
        address: '3 Rue Test',
        location: const LatLng(48.8568, 2.3524),
        type: CafeType.restaurant,
        availableCoffeeTypes: [CoffeeType.espresso, CoffeeType.cappuccino],
      ),
    ];

    test('should filter by cafe type', () {
      final cafesOnly = testCafes.where((c) => c.type == CafeType.cafe).toList();
      
      expect(cafesOnly.length, 1);
      expect(cafesOnly.first.name, 'Café Test 1');
    });

    test('should filter by multiple types', () {
      final filteredCafes = testCafes
          .where((c) => c.type == CafeType.cafe || c.type == CafeType.bar)
          .toList();

      expect(filteredCafes.length, 2);
    });

    test('should filter by coffee type', () {
      final espressoCafes = testCafes
          .where((c) => c.availableCoffeeTypes.contains(CoffeeType.espresso))
          .toList();

      expect(espressoCafes.length, 2);
    });

    test('should filter by multiple coffee types', () {
      final filteredCafes = testCafes
          .where((c) =>
              c.availableCoffeeTypes.contains(CoffeeType.espresso) ||
              c.availableCoffeeTypes.contains(CoffeeType.americano))
          .toList();

      expect(filteredCafes.length, 3);
    });
  });

  group('Cafe Model Tests', () {
    test('should calculate distance between two locations', () {
      final cafe = Cafe(
        id: '1',
        name: 'Test Cafe',
        address: 'Test Address',
        location: const LatLng(48.8566, 2.3522), // Paris
        type: CafeType.cafe,
      );

      final otherLocation = const LatLng(48.8606, 2.3376); // ~1km away
      final distance = cafe.distanceFrom(otherLocation);

      expect(distance, greaterThan(0));
      expect(distance, lessThan(2)); // Should be less than 2km
    });

    test('should format distance correctly', () {
      final cafe = Cafe(
        id: '1',
        name: 'Test Cafe',
        address: 'Test Address',
        location: const LatLng(48.8566, 2.3522),
        type: CafeType.cafe,
      );

      final nearbyLocation = const LatLng(48.8606, 2.3376);
      final distanceText = cafe.distanceTextFrom(nearbyLocation);

      expect(distanceText.isNotEmpty, true);
    });

    test('should create cafe with all required properties', () {
      final cafe = Cafe(
        id: '1',
        name: 'Test Cafe',
        address: 'Test Address',
        location: const LatLng(48.8566, 2.3522),
        type: CafeType.cafe,
        availableCoffeeTypes: [CoffeeType.espresso],
      );

      expect(cafe.id, '1');
      expect(cafe.name, 'Test Cafe');
      expect(cafe.address, 'Test Address');
      expect(cafe.type, CafeType.cafe);
      expect(cafe.availableCoffeeTypes.length, 1);
    });
  });

  group('CafeType Enum Tests', () {
    test('should have correct number of cafe types', () {
      expect(CafeType.values.length, 5);
    });

    test('should have display names and emojis', () {
      expect(CafeType.cafe.displayName, 'Café');
      expect(CafeType.cafe.emoji, '☕');
      expect(CafeType.restaurant.displayName, 'Restaurant');
      expect(CafeType.restaurant.emoji, '🍽️');
      expect(CafeType.bar.displayName, 'Bar');
      expect(CafeType.bar.emoji, '🍷');
      expect(CafeType.vendingMachine.displayName, 'Distributeur');
      expect(CafeType.vendingMachine.emoji, '🏪');
      expect(CafeType.bakery.displayName, 'Boulangerie');
      expect(CafeType.bakery.emoji, '🥐');
    });
  });

  group('CoffeeType Enum Tests', () {
    test('should have correct number of coffee types', () {
      // 10 types avec caféine
      expect(CoffeeType.values.length, 10);
    });

    test('should have display names and emojis', () {
      expect(CoffeeType.espresso.displayName, 'Espresso');
      expect(CoffeeType.espresso.emoji, '☕');
      expect(CoffeeType.cappuccino.displayName, 'Cappuccino');
      expect(CoffeeType.latte.displayName, 'Latte');
      expect(CoffeeType.mocha.displayName, 'Mocha');
      expect(CoffeeType.americano.displayName, 'Americano');
    });
  });
}
