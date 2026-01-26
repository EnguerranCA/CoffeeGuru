import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/cafe_place.dart';
import 'package:flutter_application_1/services/cafe_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  late CafeService cafeService;

  setUp(() {
    cafeService = CafeService();
  });

  group('CafeService Basic Operations', () {
    test('should load demo cafes', () async {
      final position = LatLng(48.8566, 2.3522); // Paris
      
      await cafeService.loadDemoCafes(position);
      
      expect(cafeService.getAllCafes().length, greaterThan(0));
    });

    test('should get cafe by ID', () async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);

      final cafe = cafeService.getCafeById('1');

      expect(cafe, isNotNull);
      expect(cafe!.id, '1');
      expect(cafe.name, isNotEmpty);
    });

    test('should return null for non-existent ID', () async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);

      final cafe = cafeService.getCafeById('non_existent_id');

      expect(cafe, isNull);
    });

    test('should return all cafes', () async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);

      final cafes = cafeService.getAllCafes();

      expect(cafes, isNotEmpty);
      expect(cafes.length, greaterThanOrEqualTo(5));
    });
  });

  group('CafeService Filtering', () {
    setUp(() async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);
    });

    test('should filter cafes by type', () {
      final cafes = cafeService.filterByType([CafeType.cafe]);

      expect(cafes, isNotEmpty);
      expect(cafes.every((cafe) => cafe.type == CafeType.cafe), isTrue);
    });

    test('should filter cafes by multiple types', () {
      final cafes = cafeService.filterByType([CafeType.cafe, CafeType.bar]);

      expect(cafes, isNotEmpty);
      expect(
        cafes.every((cafe) => cafe.type == CafeType.cafe || cafe.type == CafeType.bar),
        isTrue,
      );
    });

    test('should return all cafes when no type filter', () {
      final allCafes = cafeService.getAllCafes();
      final filteredCafes = cafeService.filterByType([]);

      expect(filteredCafes.length, allCafes.length);
    });

    test('should filter cafes by coffee type', () {
      final cafes = cafeService.filterByCoffeeType([CoffeeType.espresso]);

      expect(cafes, isNotEmpty);
      expect(
        cafes.every((cafe) => cafe.availableCoffeeTypes.contains(CoffeeType.espresso)),
        isTrue,
      );
    });

    test('should filter cafes by multiple coffee types', () {
      final cafes = cafeService.filterByCoffeeType([
        CoffeeType.espresso,
        CoffeeType.cappuccino,
      ]);

      expect(cafes, isNotEmpty);
      expect(
        cafes.every((cafe) =>
            cafe.availableCoffeeTypes.contains(CoffeeType.espresso) ||
            cafe.availableCoffeeTypes.contains(CoffeeType.cappuccino)),
        isTrue,
      );
    });

    test('should return all cafes when no coffee type filter', () {
      final allCafes = cafeService.getAllCafes();
      final filteredCafes = cafeService.filterByCoffeeType([]);

      expect(filteredCafes.length, allCafes.length);
    });
  });

  group('CafeService Search', () {
    setUp(() async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);
    });

    test('should search cafes by name (case insensitive)', () {
      final cafes = cafeService.searchByName('café');

      expect(cafes, isNotEmpty);
      expect(
        cafes.every((cafe) => cafe.name.toLowerCase().contains('café')),
        isTrue,
      );
    });

    test('should search cafes by partial name', () {
      final cafes = cafeService.searchByName('petit');

      expect(cafes, isNotEmpty);
      expect(
        cafes.any((cafe) => cafe.name.toLowerCase().contains('petit')),
        isTrue,
      );
    });

    test('should return empty list for non-matching search', () {
      final cafes = cafeService.searchByName('xyz_nonexistent_cafe_123');

      expect(cafes, isEmpty);
    });

    test('should be case insensitive', () {
      final cafesLower = cafeService.searchByName('café');
      final cafesUpper = cafeService.searchByName('CAFÉ');
      final cafesMixed = cafeService.searchByName('CaFé');

      expect(cafesLower.length, equals(cafesUpper.length));
      expect(cafesLower.length, equals(cafesMixed.length));
    });
  });

  group('CafeService Proximity', () {
    test('should get cafes nearby within radius', () async {
      final position = LatLng(48.8566, 2.3522); // Paris
      await cafeService.loadDemoCafes(position);

      final nearbyCafes = cafeService.getCafesNearby(position, radiusKm: 5.0);

      expect(nearbyCafes, isNotEmpty);
      expect(
        nearbyCafes.every((cafe) => cafe.distanceFrom(position) <= 5.0),
        isTrue,
      );
    });

    test('should sort cafes by distance (closest first)', () async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);

      final nearbyCafes = cafeService.getCafesNearby(position, radiusKm: 10.0);

      if (nearbyCafes.length > 1) {
        for (int i = 0; i < nearbyCafes.length - 1; i++) {
          final currentDistance = nearbyCafes[i].distanceFrom(position);
          final nextDistance = nearbyCafes[i + 1].distanceFrom(position);
          expect(currentDistance, lessThanOrEqualTo(nextDistance));
        }
      }
    });

    test('should filter out cafes outside radius', () async {
      final position = LatLng(48.8566, 2.3522);
      await cafeService.loadDemoCafes(position);

      final nearbyCafes = cafeService.getCafesNearby(position, radiusKm: 0.1);

      // Tous les cafés doivent être dans un rayon de 100m
      expect(
        nearbyCafes.every((cafe) => cafe.distanceFrom(position) <= 0.1),
        isTrue,
      );
    });
  });

  group('CafeService Singleton', () {
    test('should return same instance', () {
      final service1 = CafeService();
      final service2 = CafeService();

      expect(service1, same(service2));
    });
  });
}
