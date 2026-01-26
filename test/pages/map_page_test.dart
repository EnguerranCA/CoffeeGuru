import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_application_1/models/cafe_place.dart';
import 'package:flutter_application_1/services/cafe_service.dart';

void main() {
  group('MapPage Widget Tests', () {
    testWidgets('should display filter button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should display location button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('should show loading or content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      // Vérifier que la page se charge
      expect(find.byType(MapPage), findsOneWidget);
    });
  });

  group('MapPage Integration Tests', () {
    test('CafeService should be accessible', () {
      final service = CafeService();
      expect(service, isNotNull);
    });

    test('CafeType enums should be available for filtering', () {
      final types = CafeType.values;
      expect(types.length, greaterThan(0));
      expect(types.any((t) => t.displayName.isNotEmpty), isTrue);
    });

    test('CoffeeType enums should be available for filtering', () {
      final types = CoffeeType.values;
      expect(types.length, greaterThan(0));
      expect(types.any((t) => t.displayName.isNotEmpty), isTrue);
    });
  });

  group('MapPage State Tests', () {
    testWidgets('should have Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
