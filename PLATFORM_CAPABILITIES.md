# Platform capabilities

2026-11-07. “Implemented” below means source exists, not hardware verified.

| Platform | App-owned playback | Session effects | Output monitoring | System-wide / hardware control |
| --- | --- | --- | --- | --- |
| Android | Implemented, build/hardware pending | Native Equalizer, runtime-dependent | AudioDeviceCallback; MediaPlayer routedDevice during playback | Not implemented |
| Windows | Not implemented | Not implemented | Not implemented | Not implemented |
| macOS | Not implemented | Not implemented | Not implemented | Not implemented |
| iOS | Not implemented | Not implemented | Not implemented | General unrelated-app modification unsupported |
| Linux / web | Not implemented | Not implemented | Not implemented | Not implemented |

All hosts retain the Flutter UI. A missing method-channel adapter disables playback and processing controls. Android EQ availability is checked after preparing a file, not inferred from OS identity. Device effect failure is displayed while plain playback remains possible. Available outputs are not necessarily the current route; the current route is queried from the playing MediaPlayer. On API 23 the actual playback route cannot be reported by this adapter.

Android selects files through ACTION_OPEN_DOCUMENT; it does not request broad storage access, capture consent, microphone access, or Bluetooth pairing permissions. MODIFY_AUDIO_SETTINGS permits session effects. Routing stays with the OS. A wired endpoint name is not proof of a unique AUX speaker. No device profile identity is currently persisted.

Future options require distinct investigation: Windows WASAPI application rendering versus virtual endpoint/APO deployment; macOS app rendering versus virtual routing; iOS AVAudioEngine/AVAudioSession in-app playback. Loopback capture alone cannot replace original playback. No driver or system effect is installed.

References: [Android MediaPlayer](https://developer.android.com/reference/android/media/MediaPlayer), [session Equalizer](https://developer.android.com/reference/android/media/audiofx/Equalizer), [audio focus](https://developer.android.com/media/optimize/audio-focus).
