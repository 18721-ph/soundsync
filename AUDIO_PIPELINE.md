# Audio pipeline

## Current Android implementation

User-selected document URI -> MediaPlayer platform decoder -> Android media session with Equalizer -> OS-managed output (speaker, Bluetooth, wired, USB where supported).

`android/app/src/main/kotlin/com/example/soundsync/AudioAdapter.kt` owns the source and session. `lib/services/audio_controller.dart` carries commands and native state over `soundsync/audio`. `SoundProfileService` supplies presets; the existing dashboard sends changes to the adapter.

Android's effect bands are discovered at runtime. Bands with center frequency below 250 Hz receive Bass, 250–3999 Hz Midrange, and >=4000 Hz Treble. Requests are clamped to the effect's millibel limits. These are grouped native bands, not three portable parametric filters. Platforms may provide different center frequencies, limits and audible results.

Playback gain is `volume * 10^(-maxPositiveRequestedBandDb/20)` when EQ is active; bypass disables EQ and removes that attenuation while preserving the master level. This reserves nominal output headroom. The adapter cannot guarantee internal pre-EQ ordering or prevent every inter-stage peak. There is no shared peak limiter, compression, stereo balance, coefficient smoothing, or real-time PCM callback yet. Bypass and gain changes are not claimed click-free.

File preparation is asynchronous. Playback requires explicit Play and audio focus. Backgrounding, focus loss (including duck requests), and output removal pause playback without automatic restart. Completion abandons focus. Activity destruction releases player, effect, callbacks and channel handler. Playback does not continue in a foreground service.

No third-party stream capture, global session-zero effect, hardware EQ command, or capture-and-replay path is present.

## Required next engine

Implement shared C++ float PCM processing with validated formats, preallocated state, finite-value handling, mono/stereo tests, gain/EQ/limiter and smoothed thread-safe control updates. Integrate at native decode/render boundaries; keep PCM off method channels. Measure frequency response, peak behavior, latency and transitions before reporting DSP milestones complete.
