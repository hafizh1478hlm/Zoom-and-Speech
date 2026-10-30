import 'package:flutter_test/flutter_test.dart';
import 'package:zoom_and_speech/app.dart';

void main() {
  testWidgets('app starts and shows welcome screen', (tester) async {
    await tester.pumpWidget(const ZoomAndSpeechApp());
    await tester.pumpAndSettle();

    expect(find.text('Zoom Or Speech'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Lewati, langsung scan'), findsOneWidget);
  });

  testWidgets('skip login goes to scan screen', (tester) async {
    await tester.pumpWidget(const ZoomAndSpeechApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati, langsung scan'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Teks'), findsOneWidget);
    expect(find.text('Ambil Foto'), findsOneWidget);
  });
}