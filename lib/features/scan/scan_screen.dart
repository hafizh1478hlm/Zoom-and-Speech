import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/ocr_service.dart';
import '../../core/theme/app_colors.dart';
import '../settings/voice_settings_screen.dart';

class ScanScreen extends StatefulWidget {
  final Function(XFile image, OcrResult ocrResult)? onOcrCompleted;

  const ScanScreen({
    super.key,
    this.onOcrCompleted,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  XFile? _selectedImage;
  bool _isLoading = false;
  String _loadingMessage = '';
  final int _currentNavIndex = 0;

  // US-10: mengingat sumber gambar terakhir (kamera/galeri)
  ImageSource _lastSource = ImageSource.camera;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    _lastSource = source;

    try {
      setState(() {
        _isLoading = true;
        _loadingMessage = source == ImageSource.camera
            ? 'Membuka kamera...'
            : 'Membuka galeri...';
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _selectedImage = image;
        _loadingMessage = 'Membaca tulisan pada gambar (OCR)...';
      });

      // Proses OCR (US-02)
      final OcrResult result = await _ocrService.processImage(image.path);

      if (!mounted) return;

      if (widget.onOcrCompleted != null) {
        widget.onOcrCompleted!(image, result);
      } else {
        if (result.isSuccess) {
          _showOcrSuccessDialog(image, result);
        } else {
          _showOcrFailedDialog(result.errorMessage ?? 'Gagal membaca teks.');
        }
      }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terjadi kesalahan saat membaca gambar. Silakan coba lagi.'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOcrSuccessDialog(XFile image, OcrResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Teks Berhasil Dibaca!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image.path),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Teks yang ditemukan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    result.fullText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedImage = null);
            },
            child: const Text(
              'Scan Ulang',
              style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjut ke Hasil'),
          ),
        ],
      ),
    );
  }

  void _showOcrFailedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Teks Tidak Terdeteksi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedImage = null);
            },
              child: const Text(
                'Tutup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _selectedImage = null);
                  _pickAndProcessImage(_lastSource);
                },
                child: const Text('Ambil Ulang'),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Scan Teks',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Arahkan kamera ke tulisan yang ingin dibaca',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              // Viewfinder frame area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Preview Gambar atau Mockup Panduan
                      if (_selectedImage != null)
                        Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KOMPOSISI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tepung terigu, gula, minyak nabati, susu bubuk, garam, pengembang (E500)...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Loading Overlay saat OCR berjalan
                      if (_isLoading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 3.5,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _loadingMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bingkai Sudut Putih (Corner Brackets)
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: Padding(
                            padding: EdgeInsets.all(18),
                            child: _CornerBracketsOverlay(),
                          ),
                        ),
                      ),

                      // Kapsul Status: Zoom + Suara aktif
                      Positioned(
                        bottom: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Zoom + Suara aktif',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Kotak Tips Aksesibilitas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border(
                    left: BorderSide(
                      color: AppColors.accent,
                      width: 5,
                    ),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Tips: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'pastikan cahaya cukup agar tulisan terbaca jelas.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Utama: Ambil Foto
              FilledButton.icon(
                onPressed: _isLoading ? null : () => _pickAndProcessImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, size: 28),
                label: const Text('Ambil Foto'),
              ),
              const SizedBox(height: 10),

              // Opsi Pendukung: Pilih dari Galeri
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _pickAndProcessImage(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.primary, width: 1.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.photo_library_outlined, size: 24, color: AppColors.primary),
                label: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
                );
            }
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.crop_free_rounded, size: 28),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_rounded, size: 28),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 28),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracketsOverlay extends StatelessWidget {
  const _CornerBracketsOverlay();

  @override
  Widget build(BuildContext context) {
    const double length = 32.0;
    const double thickness = 4.0;
    const Color color = Colors.white;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: length,
            height: length,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: length,
            height: length,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: length,
            height: length,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: length,
            height: length,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
