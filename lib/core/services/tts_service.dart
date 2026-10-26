import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan kecepatan bicara (US-07, AC 1).
enum SpeechSpeed {
  slow('Lambat', 0.3),
  normal('Normal', 0.45),
  fast('Cepat', 0.65);

  final String label;
  final double rate;
  const SpeechSpeed(this.label, this.rate);
}

/// Mengatur suara pembacaan teks.
/// terpisah dari volume sistem HP (US-07, AC 2).
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  static const _kSpeed = 'tts_speed';
  static const _kVolume = 'tts_volume';

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  SpeechSpeed _speed = SpeechSpeed.normal;
  double _volume = 1.0;

  SpeechSpeed get speed => _speed;
  double get volume => _volume;

  /// Memuat pengaturan tersimpan dan menerapkannya ke mesin TTS.
  Future<void> init() async {
    if (_ready) return;

    final prefs = await SharedPreferences.getInstance();

    final speedIndex = prefs.getInt(_kSpeed) ?? SpeechSpeed.normal.index;
    _speed = (speedIndex >= 0 && speedIndex < SpeechSpeed.values.length)
        ? SpeechSpeed.values[speedIndex]
        : SpeechSpeed.normal;

    final savedVolume = prefs.getDouble(_kVolume) ?? 1.0;
    _volume = savedVolume.clamp(0.1, 1.0).toDouble();

    await _tts.setLanguage('id-ID');
    await _tts.setPitch(1.0);
    await _apply();
    _ready = true;
  }

  Future<void> _apply() async {
    await _tts.setSpeechRate(_speed.rate);
    await _tts.setVolume(_volume);
  }

  Future<void> setSpeed(SpeechSpeed speed) async {
    await init();
    _speed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSpeed, speed.index);
    await _apply();
  }

  Future<void> setVolume(double volume) async {
    await init();
    _volume = volume.clamp(0.1, 1.0).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolume, _volume);
    await _apply();
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}