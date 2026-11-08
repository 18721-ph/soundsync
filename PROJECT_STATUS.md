# Sound Sync project recovery

Audit date: 2026-11-07. Baseline: `3d46959` (404 page); clean tracked worktree.

## Recovered state

- Flutter/Dart application, Material UI, no backend or third-party audio dependencies (`pubspec.yaml`).
- `lib/main.dart`: responsive dashboard, three presets, EQ sliders, volume state, simulated connection, unknown-route page. No audio stream exists at baseline.
- `lib/services/sound_profile_service.dart`: in-memory three-band settings and preset selection; no storage or audio calls.
- `test/`: seven widget tests and two service tests. These verify UI/state only.
- Android `MainActivity.kt`, Windows `flutter_window.cpp`, macOS `MainFlutterWindow.swift`, iOS `AppDelegate.swift`, Linux runner and web bootstrap are generated hosts without audio adapters.
- Git history contains 18 commits starting at `59f9f2b`. `89f4a63` separated audio settings; `0e1117a` improved UI; `3d46959` added the 404 page. Commit descriptions are not evidence of DSP functionality.
- Shared conversation URL returned no readable conversation; no missing history inferred.

## Continuation decision

Preserve Flutter and existing layout. First integrate Android application-owned playback with native session EQ, an explicitly permitted platform implementation. This is a bounded first integration, not a completed cross-platform DSP engine. Native EQ avoids introducing a decoder, JNI and callback pipeline before any supported playback source exists. Shared PCM DSP remains a separate milestone.

Build, test and hardware evidence is recorded in TEST_REPORT.md. Platform project folders alone do not establish supported audio processing.
