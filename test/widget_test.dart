import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echo_grid/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash plays, lands on menu, Play starts the game',
      (tester) async {
    await tester.pumpWidget(const MemoryApp());

    // Splash: logo flashes then title appears.
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('Echo Grid'), findsOneWidget);

    // Auto-advance to landing.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Best score'), findsOneWidget);

    // Start a game.
    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Watch closely…'), findsOneWidget);

    // Let pending playback timers resolve so the test ends cleanly.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
