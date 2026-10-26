
import 'package:flutter/material.dart';

void main() {
  runApp(const SoundSyncApp());
}

enum SoundProfile {
  balanced,
  bassBoost,
  clearVoice,
}

String profileName(SoundProfile profile) {
  switch (profile) {
    case SoundProfile.balanced:
      return 'Balanced';
    case SoundProfile.bassBoost:
      return 'Bass Boost';
    case SoundProfile.clearVoice:
      return 'Clear Voice';
  }
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

              // Bluetooth device card.
              _DashboardCard(
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isConnected
                          ? 'This is a simulated connection.'
                          : 'Real Bluetooth detection is not implemented yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const Key('demo-connection-button'),
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
                        isConnected
                            ? 'Disconnect demo'
                            : 'Try demo connection',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Volume card.
              _DashboardCard(
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
                      key: const Key('volume-value'),
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    Slider(
                      key: const Key('volume-slider'),
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

              // Sound profiles.
              const Text(
                'Sound profiles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the listening experience you prefer.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),

              _ProfileOption(
                title: 'Balanced',
                description: 'A neutral everyday listening preset.',
                icon: Icons.tune,
                isSelected: selectedProfile == SoundProfile.balanced,
                onTap: () => selectProfile(SoundProfile.balanced),
              ),
              const SizedBox(height: 10),
              _ProfileOption(
                title: 'Bass Boost',
                description: 'Designed to emphasize low frequencies.',
                icon: Icons.graphic_eq,
                isSelected: selectedProfile == SoundProfile.bassBoost,
                onTap: () => selectProfile(SoundProfile.bassBoost),
              ),
              const SizedBox(height: 10),
              _ProfileOption(
                title: 'Clear Voice',
                description: 'Designed with speech clarity in mind.',
                icon: Icons.record_voice_over,
                isSelected: selectedProfile == SoundProfile.clearVoice,
                onTap: () => selectProfile(SoundProfile.clearVoice),
              ),

              const SizedBox(height: 12),
              Text(
                'Selected: ${profileName(selectedProfile)}',
                key: const Key('selected-profile-label'),
                style: const TextStyle(
                  color: Color(0xFF16C7A0),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 28),

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

              const _FeatureTile(
                icon: Icons.bluetooth,
                title: 'Real device detection',
                subtitle: 'Identify your active audio output.',
              ),
              const _FeatureTile(
                icon: Icons.equalizer,
                title: 'Sound calibration',
                subtitle: 'Explore settings for clearer audio.',
              ),
              const _FeatureTile(
                icon: Icons.bookmark_outline,
                title: 'Saved speaker profiles',
                subtitle: 'Keep your preferred settings.',
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'SoundSync • Early prototype',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectProfile(SoundProfile profile) {
    setState(() {
      selectedProfile = profile;
    });
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151F30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF263448)),
      ),
      child: child,
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF16C7A0);

    return Material(
      color: isSelected
          ? const Color(0xFF18352F)
          : const Color(0xFF151F30),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key(
          'profile-${title.toLowerCase().replaceAll(' ', '-')}',
        ),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accent : const Color(0xFF263448),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? accent : Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? accent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: accent,
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
