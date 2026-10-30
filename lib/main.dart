import 'package:flutter/material.dart';

import 'services/sound_profile_service.dart';

const _canvas = Color(0xFF0B1220),
    _surface = Color(0xFF151F30),
    _raised = Color(0xFF1B293C),
    _border = Color(0xFF263448),
    _mint = Color(0xFF16C7A0),
    _text = Color(0xFFF5F7FA),
    _muted = Color(0xFF9AA9BC),
    _amber = Color(0xFFF6B84A);

void main() => runApp(const SoundSyncApp());

class SoundSyncApp extends StatelessWidget {
  const SoundSyncApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SoundSync',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _canvas,
      colorScheme: const ColorScheme.dark(
        primary: _mint,
        onPrimary: _canvas,
        surface: _surface,
        onSurface: _text,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _mint,
        inactiveTrackColor: _border,
        thumbColor: _text,
        overlayColor: Color(0x3316C7A0),
        trackHeight: 5,
      ),
    ),
    home: const SoundSyncHome(),
  );
}

class SoundSyncHome extends StatefulWidget {
  const SoundSyncHome({super.key});
  @override
  State<SoundSyncHome> createState() => _SoundSyncHomeState();
}

class _SoundSyncHomeState extends State<SoundSyncHome> {
  final SoundProfileService soundProfileService = SoundProfileService();
  double volume = 50;
  bool isConnected = false;
  @override
  void dispose() {
    soundProfileService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedBuilder(
        animation: soundProfileService,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 920;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 480 ? 16 : 28,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: desktop ? 1180 : 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(connected: isConnected),
                      const SizedBox(height: 38),
                      const _Intro(),
                      const SizedBox(height: 28),
                      if (desktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _DeviceCard(
                                connected: isConnected,
                                onToggle: _toggle,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 9,
                              child: _VolumeCard(
                                value: volume,
                                onChanged: _setVolume,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _DeviceCard(connected: isConnected, onToggle: _toggle),
                        const SizedBox(height: 20),
                        _VolumeCard(value: volume, onChanged: _setVolume),
                      ],
                      const SizedBox(height: 36),
                      const _Heading(
                        eyebrow: 'LISTENING MODE',
                        title: 'Sound profiles',
                        subtitle: 'Choose a tuned starting point, then make it yours.',
                      ),
                      const SizedBox(height: 16),
                      _ProfileGrid(
                        selected: soundProfileService.selectedProfile,
                        onSelect: soundProfileService.selectProfile,
                      ),
                      const SizedBox(height: 36),
                      _EqualizerCard(service: soundProfileService),
                      const SizedBox(height: 36),
                      const _Heading(
                        eyebrow: 'ON THE HORIZON',
                        title: 'Coming next',
                        subtitle: 'Built-in features currently in development.',
                      ),
                      const SizedBox(height: 16),
                      const _FeatureGrid(),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'SoundSync • Early prototype',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  void _toggle() => setState(() => isConnected = !isConnected);
  void _setVolume(double value) => setState(() => volume = value);
}

class _Header extends StatelessWidget {
  const _Header({required this.connected});
  final bool connected;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const _IconBox(icon: Icons.graphic_eq_rounded, color: _mint),
      const SizedBox(width: 12),
      const Expanded(
        child: Text(
          'SoundSync',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      _ConnectionPill(connected: connected),
      const SizedBox(width: 8),
      IconButton(
        tooltip: 'Settings',
        onPressed: () {},
        icon: const Icon(Icons.settings_outlined, color: _muted),
      ),
    ],
  );
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.connected});
  final bool connected;
  @override
  Widget build(BuildContext context) {
    final color = connected ? _mint : _amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        border: Border.all(color: color.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Demo connected' : 'No device',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your sound, perfected.',
        style: TextStyle(
          fontSize: 32,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -.6,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'A better listening experience starts here.',
        style: TextStyle(color: _muted, fontSize: 15),
      ),
    ],
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.connected, required this.onToggle});
  final bool connected;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconBox(
              icon: connected
                  ? Icons.speaker_rounded
                  : Icons.speaker_group_outlined,
              color: connected ? _mint : _amber,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connected
                        ? 'Demo speaker connected'
                        : 'No speaker connected',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    connected
                        ? 'Bluetooth • Simulated connection'
                        : 'Connect a simulated speaker to explore controls.',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: _border),
        const SizedBox(height: 16),
        Text(
          connected
              ? 'This is a simulated connection.'
              : 'Real Bluetooth detection is not implemented yet.',
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('demo-connection-button'),
            style: FilledButton.styleFrom(
              backgroundColor: _mint,
              foregroundColor: _canvas,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onToggle,
            icon: Icon(
              connected
                  ? Icons.link_off_rounded
                  : Icons.bluetooth_searching_rounded,
            ),
            label: Text(connected ? 'Disconnect demo' : 'Try demo connection'),
          ),
        ),
      ],
    ),
  );
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volume control',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          '${value.round()}%',
          key: const Key('volume-value'),
          style: const TextStyle(
            fontSize: 44,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Demo output level',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.volume_down_rounded, color: _muted),
            Expanded(
              child: Slider(
                key: const Key('volume-slider'),
                value: value,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${value.round()}%',
                onChanged: onChanged,
              ),
            ),
            const Icon(Icons.volume_up_rounded, color: _muted),
          ],
        ),
        const Text(
          'This slider changes the demo value only.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.selected, required this.onSelect});
  final SoundProfile? selected;
  final ValueChanged<SoundProfile> onSelect;
  @override
  Widget build(BuildContext context) {
    final options = [
      (
        SoundProfile.balanced,
        'Balanced',
        'A neutral everyday listening preset.',
        Icons.tune_rounded,
        'profile-balanced',
      ),
      (
        SoundProfile.bassBoost,
        'Bass Boost',
        'Emphasize low-frequency sounds.',
        Icons.surround_sound_rounded,
        'profile-bass-boost',
      ),
      (
        SoundProfile.clearVoice,
        'Clear Voice',
        'Bring dialogue and vocals forward.',
        Icons.record_voice_over_rounded,
        'profile-clear-voice',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 760
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: options
              .map(
                (o) => SizedBox(
                  width: width,
                  child: _ProfileCard(
                    title: o.$2,
                    description: o.$3,
                    icon: o.$4,
                    keyName: o.$5,
                    selected: selected == o.$1,
                    onTap: () => onSelect(o.$1),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.keyName,
    required this.selected,
    required this.onTap,
  });
  final String title, description, keyName;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF173B35) : _surface,
            border: Border.all(
              color: selected ? _mint : _border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _IconBox(
                icon: icon,
                color: selected ? _mint : _muted,
                compact: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: _mint, size: 19),
            ],
          ),
        ),
      ),
    ),
  );
}

class _EqualizerCard extends StatelessWidget {
  const _EqualizerCard({required this.service});
  final SoundProfileService service;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            _IconBox(
              icon: Icons.equalizer_rounded,
              color: _mint,
              compact: true,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equalizer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Fine-tune each frequency from -12 dB to +12 dB.',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _EqualizerSlider(
          label: 'Bass',
          hint: 'Low frequencies',
          value: service.bass,
          sliderKey: const Key('bass-slider'),
          valueKey: const Key('bass-value'),
          onChanged: service.setBass,
        ),
        const SizedBox(height: 18),
        _EqualizerSlider(
          label: 'Midrange',
          hint: 'Presence and vocals',
          value: service.midrange,
          sliderKey: const Key('midrange-slider'),
          valueKey: const Key('midrange-value'),
          onChanged: service.setMidrange,
        ),
        const SizedBox(height: 18),
        _EqualizerSlider(
          label: 'Treble',
          hint: 'Clarity and detail',
          value: service.treble,
          sliderKey: const Key('treble-slider'),
          valueKey: const Key('treble-value'),
          onChanged: service.setTreble,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            key: const Key('reset-equalizer-button'),
            onPressed: service.reset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset equalizer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _text,
              side: const BorderSide(color: _border),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Prototype only: these settings do not yet change the audio your device plays.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _EqualizerSlider extends StatelessWidget {
  const _EqualizerSlider({
    required this.label,
    required this.hint,
    required this.value,
    required this.sliderKey,
    required this.valueKey,
    required this.onChanged,
  });
  final String label, hint;
  final double value;
  final Key sliderKey, valueKey;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(hint, style: const TextStyle(fontSize: 11, color: _muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _raised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value > 0 ? '+' : ''}${value.toStringAsFixed(0)} dB',
              key: valueKey,
              style: const TextStyle(
                color: _mint,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      Slider(
        key: sliderKey,
        value: value,
        min: -12,
        max: 12,
        divisions: 24,
        label: '${value.toStringAsFixed(0)} dB',
        onChanged: onChanged,
      ),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow, title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          color: _mint,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 14)),
    ],
  );
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();
  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.bluetooth_searching_rounded,
        'Real device detection',
        'Identify your active audio output.',
      ),
      (
        Icons.bookmark_added_outlined,
        'Saved sound profiles',
        'Keep preferred settings for every speaker.',
      ),
      (
        Icons.tune_rounded,
        'Advanced equalizer',
        'More bands and precise control.',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 760
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: features
              .map(
                (f) => SizedBox(
                  width: width,
                  child: _FeatureCard(icon: f.$1, title: f.$2, subtitle: f.$3),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        _IconBox(icon: icon, color: _amber, compact: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Text(
                    'SOON',
                    style: TextStyle(
                      color: _amber,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: _surface,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(22),
    ),
    child: child,
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
    this.compact = false,
  });
  final IconData icon;
  final Color color;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 42.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
      ),
      child: Icon(icon, color: color, size: compact ? 20 : 24),
    );
  }
}
