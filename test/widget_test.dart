import 'package:flutter_test/flutter_test.dart';
import 'package:zoom_and_speech/app.dart';

void main() {
  testWidgets('app starts and shows scan screen', (tester) async {
    await tester.pumpWidget(const ZoomAndSpeechApp());
    expect(find.text('Scan Teks'), findsOneWidget);
    expect(find.text('Ambil Foto'), findsOneWidget);
  });
}
