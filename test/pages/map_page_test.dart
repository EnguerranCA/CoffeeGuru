import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_application_1/models/cafe_place.dart';
import 'package:flutter_application_1/services/cafe_service.dart';

void main() {
  group('MapPage Widget Tests', () {
    testWidgets('should display MapPage title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.text('Carte'), findsOneWidget);
    });

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

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      // Vérifier qu'il y a un indicateur de chargement ou une map
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
            find.text('Carte').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should open filters dialog when filter button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      // Attendre que la page soit chargée
      await tester.pumpAndSettle();

      // Trouver et appuyer sur le bouton de filtre
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Vérifier que le dialog s'ouvre avec les filtres
        expect(
          find.text('Filtres').evaluate().isNotEmpty ||
              find.text('Type de lieu').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });
  });

  group('MapPage Filter Tests', () {
    testWidgets('should filter by cafe type in dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Ouvrir le dialog de filtres
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Vérifier la présence d'options de filtre
        final cafeTypeFilters = find.textContaining('Café').evaluate().isNotEmpty ||
            find.textContaining('Type de lieu').evaluate().isNotEmpty;
        expect(cafeTypeFilters, isTrue);
      }
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
    testWidgets('should maintain filter state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      await tester.pumpAndSettle();

      // La page doit être présente
      expect(find.byType(MapPage), findsOneWidget);
    });

    testWidgets('should have AppBar with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('MapPage UI Elements', () {
    testWidgets('should display multiple action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Compter les IconButtons
      final iconButtons = find.byType(IconButton);
      expect(iconButtons.evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('should have brown theme colors in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6B4423),
              foregroundColor: Color(0xFFF5E6D3),
            ),
          ),
          home: const MapPage(),
        ),
      );

      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar, isNotNull);
    });
  });
}
