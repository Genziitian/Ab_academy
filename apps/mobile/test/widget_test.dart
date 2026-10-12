import 'package:akhand_bharat_academy/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash shows the academy name', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AkhandBharatAcademyApp()),
    );
    await tester.pump();

    expect(find.text('Akhand Bharat Academy'), findsOneWidget);
    expect(find.text('Class 11 & 12 Crash Courses'), findsOneWidget);
  });
}
