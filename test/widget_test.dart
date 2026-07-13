import 'package:flutter_test/flutter_test.dart';
import 'package:echo_grid/main.dart';

void main() {
  testWidgets('Echo Grid boots and shows the HUD', (tester) async {
    await tester.pumpWidget(const MemoryApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Watch closely…'), findsOneWidget);

    // Let pending playback timers resolve so the test ends cleanly.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
