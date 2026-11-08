# Integration checklist

- [x] Recover repository and preserve Flutter layout/presets/404 page.
- [x] Establish method-channel control and native-state contract.
- [x] Replace simulated connection with capability-aware playback UI.
- [x] Add Android selected-file playback and session effect source code.
- [x] Add source-level focus, disconnect, background and cleanup handling.
- [ ] Compile Android adapter with installed SDK.
- [ ] Run on actual Android hardware, including an EQ-unsupported device.
- [ ] Measure EQ response, gain, bypass transitions and clipping.
- [ ] Verify Bluetooth, wired and USB routes, removal and reconnection.
- [ ] Validate picker cancellation, unreadable file, codec failure and activity recreation.
- [ ] Test focus denial, calls/interruptions, backgrounding and resource cleanup.
- [ ] Implement shared C++ PCM engine and numerical DSP tests.
- [ ] Implement device profile persistence with honest identity stability flags.
- [ ] Add Windows, macOS and iOS audio adapters and their platform tests.
- [ ] Complete performance testing, packaging and release signing.

Hardware procedure: select a known WAV containing calibrated tones; start at low device volume; compare Balanced and Bass Boost through a recorded output; measure passband changes and peaks. Repeat with wired and Bluetooth outputs. Confirm route text follows the playing endpoint. Unplug/disconnect and verify playback pauses. Deny focus, switch apps, cancel selection, select corrupt media and rotate/recreate the activity. Record device, OS, effect bands, codec and measured values in TEST_REPORT.md. Mocks do not satisfy these checks.
