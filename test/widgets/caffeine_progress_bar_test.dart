import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/caffeine_progress_bar.dart';

void main() {
  group('CaffeineProgressBar Widget Tests', () {
    testWidgets('should display caffeine information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaffeineProgressBar(
              currentCaffeine: 200,
              dailyLimit: 400,
            ),
          ),
        ),
      );

      expect(find.text('Caféine'), findsOneWidget);
      expect(find.text('200 / 400 mg'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should show green color for low caffeine', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaffeineProgressBar(
              currentCaffeine: 100, // 25%
              dailyLimit: 400,
            ),
          ),
        ),
      );

      expect(find.text('Vous êtes dans les clous ! 👍'), findsOneWidget);
    });

    testWidgets('should show warning for high caffeine', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaffeineProgressBar(
              currentCaffeine: 350, // 87.5%
              dailyLimit: 400,
            ),
          ),
        ),
      );

      expect(find.text('Vous approchez de la limite ! ⚠️'), findsOneWidget);
    });

    testWidgets('should show alert when limit exceeded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaffeineProgressBar(
              currentCaffeine: 450, // 112.5%
              dailyLimit: 400,
            ),
          ),
        ),
      );

      expect(find.text('Limite dépassée ! 🚨'), findsOneWidget);
    });
  });
}
