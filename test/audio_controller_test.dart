import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundsync/services/audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('soundsync/audio');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'missing adapter reports not implemented without pretending to play',
    () async {
      final audio = AudioController();
      await audio.initialize();
      expect(audio.playback, CapabilityStatus.notImplemented);
      expect(audio.ready, false);
      expect(audio.eqAvailable, false);
      expect(audio.playing, false);
      audio.dispose();
    },
  );

  test(
    'settings reach adapter and EQ capability depends on native response',
    () async {
      MethodCall? configuration;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'configure') configuration = call;
        return {'ready': true, 'eqAvailable': false, 'playing': false};
      });
      final audio = AudioController();
      await audio.initialize();
      expect(audio.playback, CapabilityStatus.available);
      expect(audio.equalizer, CapabilityStatus.unsupported);
      await audio.configure(
        bass: 6,
        midrange: 0,
        treble: 2,
        volume: 25,
        bypass: true,
      );
      expect(configuration!.arguments, {
        'bass': 6.0,
        'midrange': 0.0,
        'treble': 2.0,
        'volume': .25,
        'bypass': true,
      });
      audio.dispose();
    },
  );

  test('failed play reports error without optimistic playing state', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'play') {
        throw PlatformException(code: 'focus', message: 'Focus denied');
      }
      return {'ready': true, 'eqAvailable': true, 'playing': false};
    });
    final audio = AudioController();
    await audio.initialize();
    await audio.command('play');
    expect(audio.playing, false);
    expect(audio.error, 'Focus denied');
    audio.dispose();
  });

  test('late reply after disposal does not notify listeners', () async {
    final reply = Completer<Map<String, Object>>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'status') return reply.future;
      return null;
    });
    final audio = AudioController();
    final pending = audio.initialize();
    await Future<void>.delayed(Duration.zero);
    audio.dispose();
    reply.complete({'ready': true});
    await pending;
    expect(audio.ready, false);
  });

  test('native output loss updates playback and route', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'ready': true,
        'playing': true,
        'eqAvailable': true,
        'route': 'Bluetooth: Test device',
      },
    );
    final audio = AudioController();
    await audio.initialize();
    expect(audio.playing, true);
    final delivered = Completer<void>();
    messenger.handlePlatformMessage(
      'soundsync/audio',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('state', {
          'ready': true,
          'playing': false,
          'eqAvailable': true,
          'message': 'Output disconnected.',
          'outputs': <String>[],
        }),
      ),
      (_) => delivered.complete(),
    );
    await delivered.future;
    expect(audio.playing, false);
    expect(audio.route, 'No active playback route');
    expect(audio.message, 'Output disconnected.');
    audio.dispose();
  });
}
