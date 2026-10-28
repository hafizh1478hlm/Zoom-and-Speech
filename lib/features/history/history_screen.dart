import 'package:flutter/material.dart';
import '../../core/services/history_service.dart';
import '../../core/theme/app_colors.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryService.instance.getAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  /// US-09 AC 2: minta konfirmasi sebelum data benar-benar dihapus.
  Future<void> _confirmDelete(HistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: const Text(
          'Hapus riwayat ini?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Teks ini akan dihapus permanen dan tidak bisa dikembalikan.',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await HistoryService.instance.delete(item.id);
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Riwayat dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Teks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Belum ada riwayat.\nHasil scan akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          item.text.replaceAll('\n', ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            item.formattedDate,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus',
                          iconSize: 28,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _confirmDelete(item),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}