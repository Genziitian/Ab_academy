import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/lang.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'widgets/popup_host.dart';

class AkhandBharatAcademyApp extends ConsumerWidget {
  const AkhandBharatAcademyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    // Switching language: redraw everything once the new strings are set.
    ref.listen(langProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final root = WidgetsBinding.instance.rootElement;
        if (root != null) rebuildAll(root);
      });
    });

    return MaterialApp.router(
      title: 'AB Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
      locale: Locale(lang.name),
      supportedLocales: const [Locale('en'), Locale('hi')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Keep type scale stable — the design is tuned for a fixed 390pt layout.
        final clamped = MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: 1.2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clamped),
          child: PopupHost(child: child!),
        );
      },
    );
  }
}
