import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String text;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Format: dd/MM/yyyy HH:mm
  String get formattedDate {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = createdAt;
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Menyimpan hasil pemindaian ke riwayat (disimpan lokal di perangkat).
class HistoryService {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  static const _key = 'scan_history';

  /// Semua riwayat, diurutkan dari yang terbaru (US-08, AC 2).
  Future<List<HistoryItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Menambah hasil scan baru ke riwayat (US-08, AC 1).
  Future<void> add(String text) async {
    final items = await getAll();
    final now = DateTime.now();
    items.add(HistoryItem(
      id: now.microsecondsSinceEpoch.toString(),
      text: text,
      createdAt: now,
    ));
    await _save(items);
  }

  /// Menghapus satu item riwayat (US-09).
  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((e) => e.id == id);
    await _save(items);
  }

  Future<void> _save(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}