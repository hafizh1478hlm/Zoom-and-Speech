import 'package:flutter/material.dart';
import '../../core/services/history_service.dart';
import 'voice_controls.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

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
              Text(item.formattedDate, style: textTheme.bodySmall),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    item.text,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // US-07: kecepatan, volume, Bacakan, Berhenti
              VoiceControls(text: item.text),
            ],
          ),
        ),
      ),
    );
  }
}