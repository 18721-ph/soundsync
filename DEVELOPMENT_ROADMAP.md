# Development roadmap

1. Recovery: repository and history audited; baseline tests passed. Reports established.
2. First source integration: Android MediaPlayer/session EQ control path added. Compile and device validation remain gating work.
3. Shared DSP: build standalone C++ PCM core and numerical tests, then integrate an app-owned native decode/render path. Native Android EQ is a temporary platform option, not completion of this milestone.
4. Device profiles: model identifier stability, route type, user label, preset, gain and capability flags; persist locally with migration/version tests. Avoid identifying a physical AUX speaker from a jack.
5. Cross-platform playback: Windows WASAPI, Apple AVAudioEngine/Core Audio adapters, each with real route/lifecycle tests and shared processing.
6. Advanced processing: parametric bands, dynamics, limiting, balance, click-free transitions and measured latency.
7. System-level research: separately assess deployment, signing, consent and duplicate-playback risks. No privileged component installation without approval.
8. Release: hardware matrix, performance/stability evidence, accessibility, packaging and production signing.

No dates or completed hardware capabilities are inferred from scaffold folders.
