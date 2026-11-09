# soundsync

A new Flutter project.

## Running in Chrome

Run `flutter run -d chrome` for a normal browser debugging session.

If Chrome closes with `Failed to establish connection with the web debug service`
and a five-second timeout in `WebkitDebugger.enable`, use the web server instead:

```powershell
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080
```

Wait for Flutter to print the serving URL, then open http://127.0.0.1:8080 in
Chrome. Keep the terminal running. This bypasses Flutter's automatic Chrome
debugger attachment; debugging support is limited in this mode. If port 8080 is
already occupied, choose another port and open that port's URL.

In VS Code, select **SoundSync web (manual Chrome)** in Run and Debug, start it,
then open the same URL. **SoundSync Chrome (debugger)** retains the normal launch.

The web dashboard runs independently of Android Gradle. Audio playback and
equalizer processing currently have an Android adapter only, so these controls
are disabled in the browser.

See [Flutter web setup](https://docs.flutter.dev/platform-integration/web/setup)
for web-server debugging limitations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
