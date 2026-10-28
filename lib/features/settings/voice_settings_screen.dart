import 'package:flutter/material.dart';
import '../../core/services/tts_service.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final TtsService _tts = TtsService.instance;

  SpeechSpeed _speed = SpeechSpeed.normal;
  double _volume = 1.0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _tts.init();
    if (!mounted) return;
    setState(() {
      _speed = _tts.speed;
      _volume = _tts.volume;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final volumePercent = (_volume * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Suara')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // US-07 AC 1: kecepatan bicara lambat/normal/cepat
                Text('Kecepatan bicara', style: textTheme.labelLarge),
                const SizedBox(height: 12),
                SegmentedButton<SpeechSpeed>(
                  segments: [
                    for (final s in SpeechSpeed.values)
                      ButtonSegment<SpeechSpeed>(
                        value: s,
                        label: Text(s.label),
                      ),
                  ],
                  selected: {_speed},
                  onSelectionChanged: (selection) async {
                    final value = selection.first;
                    setState(() => _speed = value);
                    await _tts.setSpeed(value);
                  },
                ),
                const SizedBox(height: 32),

                // US-07 AC 2: volume terpisah dari volume sistem HP
                Text('Volume suara: $volumePercent%', style: textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  'Volume ini terpisah dari volume HP.',
                  style: textTheme.bodySmall,
                ),
                Slider(
                  value: _volume,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '$volumePercent%',
                  onChanged: (v) => setState(() => _volume = v),
                  onChangeEnd: (v) => _tts.setVolume(v),
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: () => _tts.speak(
                    'Ini contoh suara pembacaan teks dengan pengaturan Anda.',
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 28),
                  label: const Text('Tes Suara'),
                ),
              ],
            ),
    );
  }
}