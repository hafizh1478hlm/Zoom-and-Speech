import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String fullText;
  final List<String> blocks;
  final bool isSuccess;
  final String? errorMessage;

  const OcrResult({
    required this.fullText,
    this.blocks = const [],
    required this.isSuccess,
    this.errorMessage,
  });

  factory OcrResult.success(String text, List<String> blocks) {
    return OcrResult(
      fullText: text,
      blocks: blocks,
      isSuccess: true,
    );
  }

  factory OcrResult.empty() {
    return const OcrResult(
      fullText: '',
      blocks: [],
      isSuccess: false,
      errorMessage: 'Tidak ada teks yang terdeteksi. Pastikan tulisan terlihat jelas dan cahaya cukup.',
    );
  }

  factory OcrResult.failure(String message) {
    return OcrResult(
      fullText: '',
      blocks: [],
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Memproses gambar dari file path dan mengekstraksi teks di dalamnya
  Future<OcrResult> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);

      final cleanText = recognizedText.text.trim();
      if (cleanText.isEmpty) {
        return OcrResult.empty();
      }

      final blocks = recognizedText.blocks
          .map((b) => b.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      return OcrResult.success(cleanText, blocks);
    } catch (e) {
      return OcrResult.failure('Gagal memproses gambar: $e');
    }
  }

  /// Menutup resource recognizer untuk mencegah kebocoran memori (memory leak)
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}

