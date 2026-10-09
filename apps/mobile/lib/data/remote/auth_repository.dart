import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Phone-OTP and Google sign-in against Supabase Auth.
///
/// Every method is a no-op returning `false` when no backend is configured, so
/// the onboarding screens keep working on mock data.
abstract final class AuthRepo {
  static bool get enabled => Api.isReady;

  static Session? get session => enabled ? Api.auth.currentSession : null;

  static bool get isSignedIn => session != null;

  static Stream<AuthState> get changes => Api.auth.onAuthStateChange;

  /// Normalises "98765 43210" to the E.164 form Supabase expects.
  static String normalisePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final last10 = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;
    return '+91$last10';
  }

  /// Step 1 of phone sign-in: send the six-digit code.
  static Future<({bool ok, String? error})> sendOtp(String phone) async {
    if (!enabled) return (ok: true, error: null);
    try {
      await Api.auth.signInWithOtp(phone: normalisePhone(phone));
      return (ok: true, error: null);
    } on AuthException catch (e) {
      return (ok: false, error: e.message);
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Step 2: exchange the code for a session.
  static Future<({bool ok, String? error})> verifyOtp(
    String phone,
    String code,
  ) async {
    if (!enabled) return (ok: true, error: null);
    try {
      await Api.auth.verifyOTP(
        phone: normalisePhone(phone),
        token: code,
        type: OtpType.sms,
      );
      return (ok: true, error: null);
    } on AuthException catch (e) {
      return (ok: false, error: e.message);
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Deep link Supabase sends the browser back to once Google has consented.
  /// Registered as an intent-filter on Android and a CFBundleURLScheme on iOS,
  /// and must also be listed under the project's Redirect URLs.
  static const googleRedirect = 'in.akhandbharatacademy.app://login-callback';

  /// Starts Google sign-in in an external browser.
  ///
  /// `ok` means only that the browser opened — this returns immediately and the
  /// session does not exist yet. The redirect back through [googleRedirect] is
  /// what creates it, so callers must then await [awaitSignIn] rather than
  /// treating a true here as "signed in".
  static Future<({bool ok, String? error})> signInWithGoogle() async {
    if (!enabled) return (ok: true, error: null);
    try {
      await Api.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: googleRedirect,
      );
      return (ok: true, error: null);
    } on AuthException catch (e) {
      return (ok: false, error: e.message);
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Waits for the deep link to deliver the session, returning false if the
  /// user backed out of the browser instead of finishing.
  ///
  /// supabase_flutter picks the redirect up and emits `signedIn`; the timeout
  /// only stops the caller hanging on a spinner forever.
  static Future<bool> awaitSignIn({
    Duration timeout = const Duration(minutes: 3),
  }) async {
    if (!enabled) return true;
    if (isSignedIn) return true;
    try {
      await changes
          .firstWhere((state) => state.event == AuthChangeEvent.signedIn)
          .timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> signOut() async {
    if (!enabled) return;
    await Api.auth.signOut();
  }
}
