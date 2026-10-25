import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/scan/scan_screen.dart';

class ZoomAndSpeechApp extends StatelessWidget {
  const ZoomAndSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoom Or Speech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ScanScreen(),
    );
  }
}
