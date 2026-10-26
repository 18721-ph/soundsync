
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsync/main.dart';

void main() {
  testWidgets('SoundSync dashboard displays correctly', (
    WidgetTester tester,
  ) async {
    // Build the SoundSync application.
    await tester.pumpWidget(const SoundSyncApp());

    // Verify the main dashboard content appears.
    expect(find.text('SoundSync'), findsOneWidget);
    expect(find.text('Your sound, perfected.'), findsOneWidget);
    expect(find.text('Volume control'), findsOneWidget);

    // Verify the demo connection starts disconnected.
    expect(find.text('No speaker connected'), findsOneWidget);
    expect(find.text('Try demo connection'), findsOneWidget);
  });

  testWidgets('Demo connection button changes its displayed state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    // Tap the simulated connection button.
    await tester.tap(find.text('Try demo connection'));
    await tester.pump();

    // Verify the displayed state changes.
    expect(find.text('Demo speaker connected'), findsOneWidget);
    expect(find.text('Disconnect demo'), findsOneWidget);
  });
}
