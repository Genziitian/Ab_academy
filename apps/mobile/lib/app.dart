import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'widgets/popup_host.dart';

class AkhandBharatAcademyApp extends ConsumerWidget {
  const AkhandBharatAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Akhand Bharat Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // Keep type scale stable — the design is tuned for a fixed 390pt layout.
        final clamped = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clamped),
          child: PopupHost(child: child!),
        );
      },
    );
  }
}
