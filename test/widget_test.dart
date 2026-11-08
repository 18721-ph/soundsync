import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsync/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('soundsync/audio');
  var playing = false;
  setUp(() {
    playing = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'play') playing = true;
          if (call.method == 'pause') playing = false;
          return <String, Object?>{
            'ready': true,
            'playing': playing,
            'eqAvailable': true,
            'route': playing
                ? 'Wired: Test output'
                : 'No active playback route',
            'message': 'File ready. Press Play.',
            'outputs': <String>[],
          };
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  testWidgets('Missing adapter disables playback and processing', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw MissingPluginException(),
        );
    await tester.pumpWidget(const SoundSyncApp());
    await tester.pumpAndSettle();
    expect(
      find.text('Audio playback is not implemented on this platform yet.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('choose-audio-button')))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<Slider>(find.byKey(const Key('volume-slider'))).onChanged,
      isNull,
    );
    expect(
      tester.widget<Slider>(find.byKey(const Key('bass-slider'))).onChanged,
      isNull,
    );
  });
  testWidgets('SoundSync dashboard displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    expect(find.text('SoundSync'), findsOneWidget);
    expect(find.text('Your sound, perfected.'), findsOneWidget);
    expect(find.text('Volume control'), findsOneWidget);
    expect(find.text('Sound profiles'), findsOneWidget);
    expect(find.text('Equalizer'), findsOneWidget);
    expect(find.text('No active playback route'), findsOneWidget);
    expect(find.text('Choose audio file'), findsOneWidget);
  });

  testWidgets('Play button renders acknowledged playback and route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('play-pause-button')));
    await tester.pump();

    expect(find.text('Wired: Test output'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('Bass Boost preset updates equalizer values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    final bassBoost = find.byKey(const Key('profile-bass-boost'));
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    await tester.ensureVisible(bassBoost);
    await tester.tap(bassBoost);
    await tester.pump();

    final resetButton = find.byKey(const Key('reset-equalizer-button'));
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('+6 dB'), findsNothing);
    expect(find.text('+2 dB'), findsNothing);
    expect(find.text('-2 dB'), findsNothing);
    expect(find.text('+4 dB'), findsNothing);
    expect(find.text('+3 dB'), findsNothing);
    expect(find.text('0 dB'), findsNWidgets(3));
  });

  testWidgets('Dashboard lays out at narrow and wide viewport widths', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);

    for (final width in [320.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(const SoundSyncApp());
      await tester.pump();

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Unknown routes show a 404 page and return to the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundSyncApp());

    Navigator.of(tester.element(find.byType(SoundSyncHome)))
        .pushNamed('/not-a-page');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('This page missed a beat.'), findsOneWidget);

    await tester.tap(find.text('Back to SoundSync'));
    await tester.pumpAndSettle();

    expect(find.text('Your sound, perfected.'), findsOneWidget);
    expect(find.text('404'), findsNothing);
  });
}
