import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/pages/tracker_page.dart';
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

  Widget createTestWidget() {
    return MaterialApp(
      home: const TrackerPage(),
    );
  }

  group('TrackerPage Basic UI', () {
    testWidgets('should display empty state when no logs', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Aucun café enregistré'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should open add coffee dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Type de café'), findsOneWidget);
      expect(find.text('Lieu'), findsOneWidget);
    });
  });

  group('TrackerPage With Data', () {
    testWidgets('should display coffee log and statistics', (tester) async {
      final now = DateTime.now();
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: now,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('1 café'), findsOneWidget);
      expect(find.text('Espresso'), findsOneWidget);
      expect(find.text('🏠 Chez moi'), findsOneWidget);
    });

    testWidgets('should delete log after confirmation', (tester) async {
      final now = DateTime.now();
      coffeeService.addCoffeeLog(CoffeeLog(
        id: '1',
        type: CoffeeType.espresso,
        location: CoffeeLocation.home,
        timestamp: now,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Swipe to delete
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Supprimer').last);
      await tester.pumpAndSettle();

      expect(find.text('Aucun café enregistré'), findsOneWidget);
    });
  });
}
