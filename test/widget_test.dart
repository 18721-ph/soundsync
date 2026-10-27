
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsync/main.dart';

void main() {
  testWidgets('SoundSync dashboard displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    expect(find.text('SoundSync'), findsOneWidget);
    expect(find.text('Your sound, perfected.'), findsOneWidget);
    expect(find.text('Volume control'), findsOneWidget);
    expect(find.text('Sound profiles'), findsOneWidget);
    expect(find.text('Equalizer'), findsOneWidget);
    expect(find.text('No speaker connected'), findsOneWidget);
    expect(find.text('Try demo connection'), findsOneWidget);
  });

  testWidgets('Demo connection button changes displayed state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    await tester.tap(find.byKey(const Key('demo-connection-button')));
    await tester.pump();

    expect(find.text('Demo speaker connected'), findsOneWidget);
    expect(find.text('Disconnect demo'), findsOneWidget);
  });

  testWidgets('Bass Boost preset updates equalizer values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    final bassBoost = find.byKey(const Key('profile-bass-boost'));
    await tester.ensureVisible(bassBoost);
    await tester.tap(bassBoost);
    await tester.pump();

    expect(find.text('+6 dB'), findsOneWidget);
    expect(find.text('+2 dB'), findsOneWidget);
  });

  testWidgets('Clear Voice preset updates equalizer values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    final clearVoice = find.byKey(const Key('profile-clear-voice'));
    await tester.ensureVisible(clearVoice);
    await tester.tap(clearVoice);
    await tester.pump();

    expect(find.text('-2 dB'), findsOneWidget);
    expect(find.text('+4 dB'), findsOneWidget);
    expect(find.text('+3 dB'), findsOneWidget);
  });

  testWidgets('Reset equalizer returns values to zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    final bassBoost = find.byKey(const Key('profile-bass-boost'));
    await tester.ensureVisible(bassBoost);
    await tester.tap(bassBoost);
    await tester.pump();

    final resetButton = find.byKey(const Key('reset-equalizer-button'));
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('+6 dB'), findsNothing);
    expect(find.text('+2 dB'), findsNothing);
    expect(find.text('0 dB'), findsNWidgets(3));
  });
}
