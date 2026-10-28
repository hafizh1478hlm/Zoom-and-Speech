import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../scan/scan_screen.dart';

/// Halaman pembuka: pengguna bisa masuk dengan Google
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToScan(BuildContext context) {
    // pushReplacement agar tombol back dari halaman scan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  void _signInWithGoogle(BuildContext context) {
    // TODO: sambungkan ke Google Sign-In.
    _goToScan(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Aa',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Judul dan subjudul
                      Text('Zoom Or Speech', style: textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Baca tulisan jadi lebih mudah',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Arahkan kamera ke tulisan, lalu lihat hasilnya dalam huruf besar sekaligus dengarkan suaranya.',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol masuk dengan Google
              FilledButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                label: const Text('Masuk dengan Google'),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () => _goToScan(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
                child: const Text('Lewati, langsung scan'),
              ),
              const SizedBox(height: 24),

              Text(
                'Login hanya diperlukan jika Anda ingin menyimpan riwayat scan.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}