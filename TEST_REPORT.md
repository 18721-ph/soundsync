# Test report

Environment: Windows 11; Flutter 3.47.8 stable / Dart 3.13.7. Date: 2026-11-07.

## Baseline

`flutter test`: **9 passed**, covering preset state, dashboard layout, simulated connection and 404 navigation at commit `3d46959`.

`flutter doctor -v`: Android SDK absent; Windows Visual Studio C++/CMake/SDK components incomplete. Windows, Chrome and Edge detected; no Android device. Apple builds require an Apple toolchain and were not run.

## Integration validation

Final automated results will be recorded after the implementation checks complete. Flutter controller tests use mocked native messages and cannot establish Android compilation, native effect availability, output routing or audible processing.

## Unverified

No Bluetooth/wired/USB hardware playback, frequency-response recording, distortion/limiter measurement, callback performance, Android lifecycle instrumentation or native compilation has been performed. No DSP numerical suite exists because this iteration uses platform EQ and does not implement the shared PCM engine. See INTEGRATION_CHECKLIST.md for the hardware protocol.
