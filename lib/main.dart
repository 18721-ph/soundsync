import 'package:flutter/material.dart';

import 'services/sound_profile_service.dart';
import 'services/audio_controller.dart';

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
    onUnknownRoute: (_) =>
        MaterialPageRoute<void>(builder: (_) => const _NotFoundPage()),
    home: const SoundSyncHome(),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _mint.withValues(alpha: .10),
                  border: Border.all(color: _mint.withValues(alpha: .35)),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: _mint,
                  size: 34,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '404',
                style: TextStyle(
                  color: _mint,
                  fontSize: 64,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This page missed a beat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We couldn't find the page you're looking for.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 15),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to SoundSync'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SoundSyncHome extends StatefulWidget {
  const SoundSyncHome({super.key});
  @override
  State<SoundSyncHome> createState() => _SoundSyncHomeState();
}

class _SoundSyncHomeState extends State<SoundSyncHome> {
  final SoundProfileService soundProfileService = SoundProfileService();
  final AudioController audio = AudioController();
  double volume = 50;
  @override
  void initState() {
    super.initState();
    soundProfileService.addListener(_configureAudio);
    audio.initialize();
  }

  void _configureAudio() {
    audio.configure(
      bass: soundProfileService.bass,
      midrange: soundProfileService.midrange,
      treble: soundProfileService.treble,
      volume: volume,
      bypass: audio.bypass,
    );
  }

  @override
  void dispose() {
    soundProfileService.removeListener(_configureAudio);
    soundProfileService.dispose();
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([soundProfileService, audio]),
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
                      _Header(connected: audio.playing),
                      const SizedBox(height: 38),
                      const _Intro(),
                      const SizedBox(height: 28),
                      if (desktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _DeviceCard(audio: audio),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 9,
                              child: _VolumeCard(
                                value: volume,
                                onChanged: audio.ready ? _setVolume : null,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _DeviceCard(audio: audio),
                        const SizedBox(height: 20),
                        _VolumeCard(
                          value: volume,
                          onChanged: audio.ready ? _setVolume : null,
                        ),
                      ],
                      const SizedBox(height: 36),
                      const _Heading(
                        eyebrow: 'LISTENING MODE',
                        title: 'Sound profiles',
                        subtitle: 'Choose a tuned starting point, then make it yours.',
                      ),
                      const SizedBox(height: 16),
                      IgnorePointer(
                        ignoring: !audio.eqAvailable,
                        child: Opacity(
                          opacity: audio.eqAvailable ? 1 : .45,
                          child: _ProfileGrid(
                            selected: soundProfileService.selectedProfile,
                            onSelect: audio.eqAvailable
                                ? soundProfileService.selectProfile
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      _EqualizerCard(
                        service: soundProfileService,
                        enabled: audio.eqAvailable,
                      ),
                      SwitchListTile(
                        title: const Text('Bypass equalizer'),
                        subtitle: const Text(
                          'Applies only to audio played by SoundSync.',
                        ),
                        value: audio.bypass,
                        onChanged: audio.eqAvailable
                            ? (value) => audio.configure(
                                bass: soundProfileService.bass,
                                midrange: soundProfileService.midrange,
                                treble: soundProfileService.treble,
                                volume: volume,
                                bypass: value,
                              )
                            : null,
                      ),
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
  void _setVolume(double value) {
    setState(() => volume = value);
    _configureAudio();
  }
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
        onPressed: null,
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
            connected ? 'Playing' : 'Not playing',
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
  const _DeviceCard({required this.audio});
  final AudioController audio;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio playback',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(audio.route, key: const Key('active-route')),
        const SizedBox(height: 8),
        Text(audio.message, style: const TextStyle(color: _muted)),
        if (audio.error != null) ...[
          const SizedBox(height: 8),
          Text(audio.error!, style: const TextStyle(color: _amber)),
        ],
        if (audio.outputs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Available outputs: ${audio.outputs.join(', ')}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('choose-audio-button'),
              onPressed:
                  audio.playback == CapabilityStatus.available && !audio.busy
                  ? audio.chooseFile
                  : null,
              icon: const Icon(Icons.audio_file),
              label: Text(audio.busy ? 'Choosing...' : 'Choose audio file'),
            ),
            OutlinedButton.icon(
              key: const Key('play-pause-button'),
              onPressed: audio.ready
                  ? () => audio.command(audio.playing ? 'pause' : 'play')
                  : null,
              icon: Icon(audio.playing ? Icons.pause : Icons.play_arrow),
              label: Text(audio.playing ? 'Pause' : 'Play'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Use system audio settings to choose Bluetooth, wired or USB output. Only the selected file is processed.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double>? onChanged;
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
          'SoundSync playback level',
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
          'Controls this app only. EQ boosts reserve output headroom.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.selected, required this.onSelect});
  final SoundProfile? selected;
  final ValueChanged<SoundProfile>? onSelect;
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
                    onTap: onSelect == null ? null : () => onSelect!(o.$1),
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
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    enabled: onTap != null,
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
  const _EqualizerCard({required this.service, required this.enabled});
  final SoundProfileService service;
  final bool enabled;
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
          onChanged: enabled ? service.setBass : null,
        ),
        const SizedBox(height: 18),
        _EqualizerSlider(
          label: 'Midrange',
          hint: 'Presence and vocals',
          value: service.midrange,
          sliderKey: const Key('midrange-slider'),
          valueKey: const Key('midrange-value'),
          onChanged: enabled ? service.setMidrange : null,
        ),
        const SizedBox(height: 18),
        _EqualizerSlider(
          label: 'Treble',
          hint: 'Clarity and detail',
          value: service.treble,
          sliderKey: const Key('treble-slider'),
          valueKey: const Key('treble-value'),
          onChanged: enabled ? service.setTreble : null,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            key: const Key('reset-equalizer-button'),
            onPressed: enabled ? service.reset : null,
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
          'Android session EQ: bands and gain limits vary by device. Select a file to check availability.',
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
  final ValueChanged<double>? onChanged;
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
        'More audio platforms',
        'Add native playback beyond Android.',
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
