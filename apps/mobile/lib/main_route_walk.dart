// Temporary verification harness: walks every route with real fonts so layout
// errors show up in the run log. Not part of the shipped app.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

const _routes = <String>[
  Routes.splash,
  Routes.login,
  Routes.otp,
  Routes.setupClass,
  Routes.setupStream,
  Routes.home,
  Routes.courses,
  Routes.store,
  Routes.myCourses,
  '/academics?tab=calendar',
  '/course/class-12-commerce-crash-course',
  Routes.curriculum,
  '/lesson/ch1-l3',
  '/pdf/att-1',
  Routes.live,
  Routes.liveLobby,
  Routes.liveRoom,
  Routes.tickets,
  '/ticket/t1',
  Routes.newTicket,
  Routes.notes,
  Routes.calendar,
  Routes.notifications,
  Routes.downloads,
  Routes.profile,
  '/checkout/class-12-commerce-crash-course',
  Routes.paymentSuccess,
];

void main() {
  final container = ProviderContainer();
  final router = container.read(routerProvider);

  var index = 0;
  var errors = 0;

  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    errors++;
    debugPrint(
      'ROUTEWALK-ERROR on ${_routes[index.clamp(0, _routes.length - 1)]}: '
      '${details.exception}',
    );
    previous?.call(details);
  };

  Timer.periodic(const Duration(milliseconds: 900), (timer) {
    if (index >= _routes.length) {
      debugPrint('ROUTEWALK-DONE routes=${_routes.length} errors=$errors');
      timer.cancel();
      return;
    }
    final route = _routes[index];
    debugPrint('ROUTEWALK-VISIT $route');
    router.go(route);
    index++;
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        title: 'Akhand Bharat Academy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
}
