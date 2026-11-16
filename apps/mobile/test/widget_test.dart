import 'package:akhand_bharat_academy/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash shows the academy name and tagline', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AkhandBharatAcademyApp()),
    );
    await tester.pump();

    expect(
      find.text('AB Academy', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('CLASS 12 SCIENCE'), findsOneWidget);
  });
}
