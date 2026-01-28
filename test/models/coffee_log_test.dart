import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/coffee_log.dart';

void main() {
  group('CoffeeLog Model Tests', () {
    test('should create CoffeeLog with correct properties', () {
      final timestamp = DateTime(2026, 1, 26, 14, 30);
      final log = CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: timestamp,
      );

      expect(log.id, '1');
      expect(log.type, CoffeeType.espresso);
      expect(log.location, CoffeeLocation.home);
      expect(log.timestamp, timestamp);
    });

    test('should convert to and from JSON', () {
      final timestamp = DateTime(2026, 1, 26, 14, 30);
      final log = CoffeeLog(
        id: '1',
        type: CoffeeType.cappuccino,
        location: CoffeeLocation.work,
        timestamp: timestamp,
      );

      final json = log.toJson();
      final logFromJson = CoffeeLog.fromJson(json);

      expect(logFromJson.id, log.id);
      expect(logFromJson.type, log.type);
      expect(logFromJson.location, log.location);
    });
  });

  group('Enums Tests', () {
    test('should have correct number of coffee types and locations', () {
      expect(CoffeeType.values.length, 10);
      expect(CoffeeLocation.values.length, 5);
    });

    test('should have display names and emojis', () {
      expect(CoffeeType.espresso.displayName, 'Espresso');
      expect(CoffeeType.espresso.emoji.isNotEmpty, true);
      expect(CoffeeLocation.home.displayName, 'Chez moi');
      expect(CoffeeLocation.home.emoji, '🏠');
    });

    test('should have caffeine values for all coffee types', () {
      expect(CoffeeType.espresso.caffeinemg, 63);
      expect(CoffeeType.americano.caffeinemg, 94);
      expect(CoffeeType.mocha.caffeinemg, 95);
      expect(CoffeeType.flatWhite.caffeinemg, 130);
      expect(CoffeeType.coldBrew.caffeinemg, 200);
    });
  });
}
