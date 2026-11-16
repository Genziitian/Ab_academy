import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/remote/push_service.dart';
import 'data/remote/supabase_client.dart';
import 'l10n/lang.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Both are no-ops when their config is absent, so the app still starts on
  // mock data with no env vars and no google-services.json.
  await Api.init();
  await PushService.init();

  // Read before the first frame so the app never flashes the wrong language.
  // Hindi month and weekday names for dates (calendar, deletion dates).
  await initializeDateFormatting('hi');
  await initializeDateFormatting('en');
  final lang = await loadSavedLang();
  applyLang(lang);

  runApp(
    ProviderScope(
      overrides: [initialLangProvider.overrideWithValue(lang)],
      child: const AkhandBharatAcademyApp(),
    ),
  );
}
