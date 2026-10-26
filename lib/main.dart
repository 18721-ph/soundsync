
import 'package:flutter/material.dart';


enum SoundProfile {
  balanced,
  bassBoost,
  clearVoice,
}
void main() {
  runApp(const SoundSyncApp());
}

class SoundSyncApp extends StatelessWidget {
  const SoundSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16C7A0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SoundSyncHome(),
    );
  }
}

class SoundSyncHome extends StatefulWidget {
  const SoundSyncHome({super.key});

  @override
  State<SoundSyncHome> createState() => _SoundSyncHomeState();
}

class _SoundSyncHomeState extends State<SoundSyncHome> {
  double volume = 50;
  bool isConnected = false;
  SoundProfile selectedProfile = SoundProfile.balanced;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: const Row(
          children: [
            Icon(Icons.graphic_eq, color: Color(0xFF16C7A0)),
            SizedBox(width: 10),
            Text(
              'SoundSync',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your sound, perfected.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A better listening experience starts here.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF263448)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.speaker_rounded,
                      size: 64,
                      color: Color(0xFF16C7A0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isConnected
                          ? 'Demo speaker connected'
                          : 'No speaker connected',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isConnected
                          ? 'This is a simulated connection.'
                          : 'Connect a speaker to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          isConnected = !isConnected;
                        });
                      },
                      icon: Icon(
                        isConnected
                            ? Icons.bluetooth_disabled
                            : Icons.bluetooth_searching,
                      ),
                      label: Text(
                        isConnected ? 'Disconnect demo' : 'Try demo connection',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF263448)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Volume control',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demo level: ${volume.round()}%',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    Slider(
                      value: volume,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${volume.round()}%',
                      onChanged: (newVolume) {
                        setState(() {
                          volume = newVolume;
                        });
                      },
                    ),
                    Text(
                      'This slider changes the demo value only.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF16C7A0)),
                  SizedBox(width: 8),
                  Text(
                    'Coming next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FeatureTile(
                icon: Icons.bluetooth,
                title: 'Real device detection',
                subtitle: 'Identify your active audio output.',
              ),
              _FeatureTile(
                icon: Icons.equalizer,
                title: 'Sound calibration',
                subtitle: 'Explore settings for clearer audio.',
              ),
              _FeatureTile(
                icon: Icons.bookmark_outline,
                title: 'Saved speaker profiles',
                subtitle: 'Keep your preferred settings.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151F30),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF16C7A0)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
