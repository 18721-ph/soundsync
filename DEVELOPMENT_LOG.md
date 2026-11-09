# Development log

## 2026-11-07 — Recovery and first Android integration

Before: `3d46959`, Flutter dashboard with simulated connection and local-only EQ/volume. Nine UI/state tests; no audio adapter or persistent profiles.

Changed: preserved dashboard layout and presets; added `lib/services/audio_controller.dart`; connected playback, gain, presets, EQ and bypass in `lib/main.dart`; rejected non-finite EQ settings in `sound_profile_service.dart`. Added `AudioAdapter.kt`, activity lifecycle wiring and MODIFY_AUDIO_SETTINGS permission. Replaced demo-connection assertions with native-state contract tests and added controller failure tests. Added all eight requested reports.

Verified: see TEST_REPORT.md for exact runs. Audio output is not hardware verified. Toolchain audit found no Android SDK and incomplete Windows C++ components. No migration, driver installation, global audio-setting change or release deployment performed.

Remaining: Android compilation/device testing; shared C++ engine; profile persistence; other native adapters; smoothing/limiting/compression; measured audio evidence. Next step is provision an Android SDK/device, compile this first adapter and validate the documented signal chain before extending it.
