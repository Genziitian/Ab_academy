import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';

/// Thin wrapper so the rest of the app never imports supabase_flutter
/// directly and never has to null-check the singleton.
abstract final class Api {
  static bool _ready = false;

  /// Called once from main(). A no-op without env vars, so the app still
  /// starts on mock data.
  static Future<void> init() async {
    if (!Env.hasBackend) return;
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // Supabase renamed this; the dashboard still labels it the anon key.
      publishableKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _ready = true;
  }

  static bool get isReady => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => Supabase.instance.client.auth;

  static User? get currentUser => _ready ? auth.currentUser : null;

  static String? get currentUserId => currentUser?.id;

  /// Signed URL for a file in a private bucket (recordings, notes PDFs).
  static Future<String?> signedUrl(
    String bucket,
    String path, {
    int expiresIn = 3600,
  }) async {
    if (!_ready) return null;
    try {
      return await client.storage.from(bucket).createSignedUrl(path, expiresIn);
    } catch (_) {
      return null;
    }
  }
}
