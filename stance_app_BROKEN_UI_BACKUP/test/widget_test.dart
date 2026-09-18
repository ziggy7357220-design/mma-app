// Basic smoke test for Stance.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stance_app/main.dart';
import 'package:stance_app/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Stance boots and shows onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.pumpWidget(StanceApp(state: state));

    // Pump until Splash finishes and IntroScreen appears
    bool found = false;
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.any(find.text('GET STARTED'))) {
        found = true;
        break;
      }
    }

    if (!found) {
      throw Exception('Could not find "GET STARTED" button after 5 seconds');
    }

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.text('What\'s your name?'), findsOneWidget);
    expect(find.text('Step 1 / 10'), findsOneWidget);
  });
}

