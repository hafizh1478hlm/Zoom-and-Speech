import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class ScanScreen extends StatefulWidget {
  final Function(XFile image)? onImageSelected;

  const ScanScreen({
    super.key,
    this.onImageSelected,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;
  int _currentNavIndex = 0;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(image);
        } else {
          _showImageSelectedDialog(image);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengakses ${source == ImageSource.camera ? "kamera" : "galeri"}: $e'),
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

  void _showImageSelectedDialog(XFile image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: const Text(
          'Foto Berhasil Diambil!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(image.path),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foto siap diproses dengan OCR pada tahap berikutnya.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedImage = null);
            },
            child: const Text(
              'Foto Ulang',
              style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSourceChoiceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  leading: const Icon(Icons.camera_alt_rounded, size: 32, color: AppColors.primary),
                  title: const Text(
                    'Kamera HP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text('Jepret langsung objek teks'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  leading: const Icon(Icons.photo_library_rounded, size: 32, color: AppColors.primary),
                  title: const Text(
                    'Galeri Foto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text('Pilih foto dari album HP'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                      // Isi preview: Foto hasil jepretan atau ilustrasi panduan
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
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt_rounded, size: 28),
                label: Text(_isLoading ? 'Membuka Kamera...' : 'Ambil Foto'),
              ),
              const SizedBox(height: 10),

              // Opsi Pendukung: Pilih dari Galeri (Sesuai US-01)
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
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
            setState(() => _currentNavIndex = index);
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
        // Top-Left
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
        // Top-Right
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
        // Bottom-Left
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
        // Bottom-Right
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

