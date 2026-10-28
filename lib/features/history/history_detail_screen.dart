import 'package:flutter/material.dart';
import '../../core/services/history_service.dart';
import '../../core/services/tts_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Teks')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.item.formattedDate, style: textTheme.bodySmall),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.item.text,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => TtsService.instance.speak(widget.item.text),
                icon: const Icon(Icons.volume_up_rounded, size: 28),
                label: const Text('Bacakan'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => TtsService.instance.stop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.stop_rounded, size: 24),
                label: const Text('Berhenti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}