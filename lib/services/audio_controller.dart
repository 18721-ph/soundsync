import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum CapabilityStatus {
  available,
  permissionRequired,
  unsupported,
  notImplemented,
  setupRequired,
  temporarilyUnavailable,
}

/// Control messages only: native adapters own decoding and rendering.
class AudioController extends ChangeNotifier {
  AudioController({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('soundsync/audio');
  final MethodChannel _channel;
  bool _disposed = false;
  bool busy = false;
  bool ready = false;
  bool playing = false;
  bool eqAvailable = false;
  bool bypass = false;
  String route = 'No active playback route';
  String message = 'Checking audio support...';
  String? error;
  List<String> outputs = [];
  CapabilityStatus playback = CapabilityStatus.notImplemented;
  CapabilityStatus equalizer = CapabilityStatus.temporarilyUnavailable;

  Future<void> initialize() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'state' && !_disposed) {
        _accept(Map<Object?, Object?>.from(call.arguments as Map));
      }
    });
    await command('status');
  }

  void _accept(Map<Object?, Object?> state) {
    if (_disposed) return;
    playback = CapabilityStatus.available;
    ready = state['ready'] == true;
    playing = state['playing'] == true;
    eqAvailable = state['eqAvailable'] == true;
    equalizer = eqAvailable
        ? CapabilityStatus.available
        : (ready
              ? CapabilityStatus.unsupported
              : CapabilityStatus.temporarilyUnavailable);
    bypass = state['bypass'] == true;
    route = state['route'] as String? ?? 'No active playback route';
    message = state['message'] as String? ?? 'Choose an audio file';
    error = state['error'] as String?;
    outputs = (state['outputs'] as List? ?? []).cast<String>();
    notifyListeners();
  }

  Future<void> command(String method, [Map<String, Object>? args]) async {
    if (_disposed) return;
    try {
      final state = await _channel.invokeMapMethod<Object?, Object?>(
        method,
        args,
      );
      if (state != null) _accept(state);
    } on MissingPluginException {
      if (_disposed) return;
      playback = CapabilityStatus.notImplemented;
      equalizer = CapabilityStatus.notImplemented;
      ready = playing = eqAvailable = false;
      message = 'Audio playback is not implemented on this platform yet.';
      notifyListeners();
    } on PlatformException catch (e) {
      if (_disposed) return;
      error = e.message ?? e.code;
      notifyListeners();
    }
  }

  Future<void> chooseFile() async {
    if (busy || playback != CapabilityStatus.available) return;
    busy = true;
    notifyListeners();
    try {
      await command('chooseFile');
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> configure({
    required double bass,
    required double midrange,
    required double treble,
    required double volume,
    required bool bypass,
  }) => command('configure', {
    'bass': bass,
    'midrange': midrange,
    'treble': treble,
    'volume': volume / 100,
    'bypass': bypass,
  });

  @override
  void dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
    _channel.invokeMethod<void>('release').catchError((Object _) {});
    super.dispose();
  }
}
