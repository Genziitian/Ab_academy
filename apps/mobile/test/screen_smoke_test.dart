import 'package:akhand_bharat_academy/router/app_router.dart';
import 'package:akhand_bharat_academy/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Every route in the app, with the label used in failure messages.
const _routes = <(String, String)>[
  (Routes.splash, '01 Splash'),
  (Routes.login, '02 Login'),
  (Routes.otp, '03 OTP'),
  (Routes.setupClass, '04 Setup class'),
  (Routes.setupStream, '05 Setup stream'),
  (Routes.home, '06 Home'),
  (Routes.courses, '07 My Courses'),
  ('/course/class-10-complete-batch', '08 Course details'),
  (Routes.curriculum, '09 Curriculum'),
  ('/lesson/ch1-l3', '10 Lecture'),
  ('/pdf/att-1', '11 PDF viewer'),
  (Routes.live, '12 Live sessions'),
  (Routes.liveLobby, '13 Live lobby'),
  (Routes.liveRoom, '14 Live classroom'),
  (Routes.community, '15 Community list'),
  ('/community/comm-class-10', '16 Community feed'),
  (Routes.tickets, '17 Tickets'),
  ('/ticket/t1', '18 Ticket detail'),
  (Routes.newTicket, '19 New ticket'),
  (Routes.materials, '20 Study materials'),
  (Routes.calendar, '21 Calendar'),
  (Routes.notifications, '22 Notifications'),
  (Routes.downloads, '23 Downloads'),
  (Routes.profile, '24 Profile'),
  ('/purchase/class-10-complete-batch', '25 Purchase'),
  ('/checkout/class-10-complete-batch', '26 Checkout'),
  (Routes.paymentSuccess, '27 Payment success'),
];

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('every screen builds and lays out without errors', (tester) async {
    // Deliberately wider than the 390pt design. Widget tests substitute a font
    // whose every glyph is a full em square, so text measures about twice as
    // wide here as in Plus Jakarta Sans; at 390 that reports overflows the
    // design does not have on a device. The generous surface keeps those false
    // positives out while still catching what this test is for: structural
    // layout errors (unbounded constraints, bad state, missing providers),
    // which are independent of the surface size. Overflow at the real 390pt
    // width is verified by running the app — see `lib/main_route_walk.dart`.
    tester.view.physicalSize = const Size(900, 1400);
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

    for (final (path, label) in _routes) {
      router.go(path);
      // Fixed frames rather than pumpAndSettle — the live dot and the countdowns
      // animate forever, so settling would never complete. Enough of them to let
      // the route transition finish and drop the outgoing page, which otherwise
      // briefly holds a second copy of the nav shell.
      await tester.pump();
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull, reason: '$label ($path) threw during layout');
      expect(find.byType(Scaffold), findsWidgets, reason: '$label ($path) rendered nothing');
    }

    // Unmount so pending timers (splash redirect, OTP resend, lobby countdown)
    // are cancelled in dispose before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
