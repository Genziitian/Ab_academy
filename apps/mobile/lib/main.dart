import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/remote/push_service.dart';
import 'data/remote/supabase_client.dart';

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

  runApp(const ProviderScope(child: AkhandBharatAcademyApp()));
}
