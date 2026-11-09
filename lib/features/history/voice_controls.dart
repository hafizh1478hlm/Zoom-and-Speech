import 'package:flutter/material.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_colors.dart';

/// Kontrol suara (US-07): kecepatan, volume, Bacakan, Berhenti.
/// Dipakai di halaman detail riwayat.
class VoiceControls extends StatefulWidget {
  final String text;

  const VoiceControls({super.key, required this.text});

  @override
  State<VoiceControls> createState() => _VoiceControlsState();
}

class _VoiceControlsState extends State<VoiceControls> {
  bool _ready = false;
  late double _volume;
  late SpeechSpeed _speed;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await TtsService.instance.init();
    if (!mounted) return;
    setState(() {
      _volume = TtsService.instance.volume;
      _speed = TtsService.instance.speed;
      _ready = true;
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kecepatan suara',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SpeechSpeed>(
            showSelectedIcon: false,
            segments: SpeechSpeed.values
                .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                .toList(),
            selected: {_speed},
            onSelectionChanged: (selection) {
              final chosen = selection.first;
              setState(() => _speed = chosen);
              TtsService.instance.setSpeed(chosen);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.volume_up_rounded, size: 24),
            Expanded(
              child: Slider(
                value: _volume,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(_volume * 100).round()}%',
                onChanged: (v) => setState(() => _volume = v),
                onChangeEnd: (v) => TtsService.instance.setVolume(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => TtsService.instance.speak(widget.text),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Bacakan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => TtsService.instance.stop(),
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Berhenti'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}