import 'package:akhand_bharat_academy/data/providers/feature_providers.dart';
import 'package:akhand_bharat_academy/l10n/lang.dart';
import 'package:akhand_bharat_academy/router/app_router.dart';
import 'package:akhand_bharat_academy/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Google Play's User Generated Content policy: other students' posts under a
/// lecture must be reportable from inside the app. Runs on mock data, where
/// the lecture has posts by other students and by the teacher.
void main() {
  testWidgets('posts by other students can be reported', (tester) async {
    await initializeDateFormatting('hi');
    applyLang(AppLang.en);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    router.go('/lesson/ch1-l3');
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Discussion').first);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Another student's post shows the action; the teacher's reply does not.
    expect(find.textContaining('Priya Sharma', findRichText: true), findsWidgets);
    expect(find.text('Report'), findsWidgets);

    final ticketsBefore = container.read(ticketsProvider).length;
    await tester.ensureVisible(find.text('Report').first);
    await tester.tap(find.text('Report').first);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Report this post?'), findsOneWidget);

    // Confirm: the dialog's own "Report" button is the last one on screen.
    await tester.tap(find.text('Report').last);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(container.read(ticketsProvider).length, ticketsBefore + 1);
    expect(
      container.read(ticketsProvider).first.subject,
      startsWith('Reported comment by'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
