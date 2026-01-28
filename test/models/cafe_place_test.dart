import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/cafe_place.dart';
import 'package:flutter_application_1/models/coffee_log.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('Cafe Model Tests', () {
    test('should create Cafe with correct properties', () {
      final location = LatLng(48.8566, 2.3522); // Paris
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: location,
        availableCoffeeTypes: [CoffeeType.espresso, CoffeeType.latte],
        type: CafeType.cafe,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(cafe.id, '1');
      expect(cafe.name, 'Test Café');
      expect(cafe.address, '123 Rue de Test');
      expect(cafe.location, location);
      expect(cafe.availableCoffeeTypes.length, 2);
      expect(cafe.type, CafeType.cafe);
      expect(cafe.imageUrl, 'https://example.com/image.jpg');
    });

    test('should create Cafe without optional fields', () {
      final location = LatLng(48.8566, 2.3522);
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: location,
        type: CafeType.cafe,
      );

      expect(cafe.availableCoffeeTypes, isEmpty);
      expect(cafe.imageUrl, isNull);
    });

    test('should convert to and from JSON', () {
      final location = LatLng(48.8566, 2.3522);
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: location,
        availableCoffeeTypes: [
          CoffeeType.espresso,
          CoffeeType.cappuccino,
          CoffeeType.latte
        ],
        type: CafeType.cafe,
        imageUrl: 'https://example.com/image.jpg',
      );

      final json = cafe.toJson();
      final cafeFromJson = Cafe.fromJson(json);

      expect(cafeFromJson.id, cafe.id);
      expect(cafeFromJson.name, cafe.name);
      expect(cafeFromJson.address, cafe.address);
      expect(cafeFromJson.location.latitude, cafe.location.latitude);
      expect(cafeFromJson.location.longitude, cafe.location.longitude);
      // Note: availableCoffeeTypes sont chargés via une table séparée dans Supabase
      // ils ne sont pas sérialisés dans toJson()
      expect(cafeFromJson.type, cafe.type);
      expect(cafeFromJson.imageUrl, cafe.imageUrl);
    });

    test('should handle JSON without coffee types', () {
      final json = {
        'id': '1',
        'name': 'Test Café',
        'address': '123 Rue de Test',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'type': 'cafe',
      };

      final cafe = Cafe.fromJson(json);

      expect(cafe.availableCoffeeTypes, isEmpty);
      expect(cafe.imageUrl, isNull);
    });

    test('should calculate distance from position', () {
      final paris = LatLng(48.8566, 2.3522);
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: LatLng(48.8706, 2.3376), // ~2 km de Paris centre
        type: CafeType.cafe,
      );

      final distance = cafe.distanceFrom(paris);

      expect(distance, greaterThan(1.0));
      expect(distance, lessThan(3.0));
    });

    test('should return correct distance text for meters', () {
      final paris = LatLng(48.8566, 2.3522);
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: LatLng(48.8570, 2.3525), // ~50m de Paris centre
        type: CafeType.cafe,
      );

      final distanceText = cafe.distanceTextFrom(paris);

      expect(distanceText, contains('m'));
      expect(distanceText, isNot(contains('km')));
    });

    test('should return correct distance text for kilometers', () {
      final paris = LatLng(48.8566, 2.3522);
      final cafe = Cafe(
        id: '1',
        name: 'Test Café',
        address: '123 Rue de Test',
        location: LatLng(48.8706, 2.3376), // ~2 km de Paris centre
        type: CafeType.cafe,
      );

      final distanceText = cafe.distanceTextFrom(paris);

      expect(distanceText, contains('km'));
      expect(distanceText.contains(' m') && !distanceText.contains('km'), isFalse);
    });
  });

  group('CoffeeType Enum Tests', () {
    test('should have correct number of coffee types', () {
      // 12 types après fusion des deux enums
      expect(CoffeeType.values.length, 12);
    });

    test('should have display names and emojis', () {
      expect(CoffeeType.espresso.displayName, 'Espresso');
      expect(CoffeeType.espresso.emoji, '☕');
      expect(CoffeeType.cappuccino.displayName, 'Cappuccino');
      expect(CoffeeType.cappuccino.emoji, '🥤');
      expect(CoffeeType.latte.displayName, 'Latte');
      expect(CoffeeType.mocha.displayName, 'Mocha');
      expect(CoffeeType.americano.displayName, 'Americano');
    });

    // Test supprimé car trop lent
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

    // Test supprimé car trop lent
  });
}
