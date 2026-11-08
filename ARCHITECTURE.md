# Architecture

## Baseline

`lib/main.dart` owns dashboard widgets and demo volume/connection state. `SoundProfileService` is a ChangeNotifier containing three EQ values. All seven platform folders are Flutter shells. No backend, persistence, PCM engine, device monitor or audio transport exists.

## Incremental design

Keep the existing Flutter UI and preset service. Add an audio controller with a method/event channel contract. Android owns file selection, MediaPlayer lifecycle, audio focus, session Equalizer and output monitoring. UI renders acknowledged native state and exposes errors. Other hosts report not implemented rather than pretending to connect.

The native platform adapter is the boundary for future implementations. Control messages carry settings; PCM must not cross Flutter channels per buffer. Future shared C++ DSP should run beside native decoding/rendering with preallocated buffers and thread-safe parameter publication. No driver, capture/replay, system-wide effect or UI migration is part of this integration.

Android session effects are an initial Mode B implementation on a Mode A source. They are not the proposed shared DSP engine and do not guarantee identical filters across manufacturers. EQ mapping and hardware verification limits belong in AUDIO_PIPELINE.md.
