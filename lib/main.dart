
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

    expect(find.text('No speaker connected'), findsOneWidget);
    expect(find.text('Try demo connection'), findsOneWidget);
    expect(find.text('Selected: Balanced'), findsOneWidget);
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

  testWidgets('Selecting Bass Boost updates the selected profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    await tester.tap(find.byKey(const Key('profile-bass-boost')));
    await tester.pump();

    expect(find.text('Selected: Bass Boost'), findsOneWidget);
  });

  testWidgets('Selecting Clear Voice updates the selected profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    await tester.tap(find.byKey(const Key('profile-clear-voice')));
    await tester.pump();

    expect(find.text('Selected: Clear Voice'), findsOneWidget);
  });
}
