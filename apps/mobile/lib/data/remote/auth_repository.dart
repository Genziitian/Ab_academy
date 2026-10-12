import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';
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

  static bool _googleReady = false;

  /// Google sign-in inside the app — no browser.
  ///
  /// Android shows its own account sheet (Credential Manager) over the app;
  /// the chosen account's ID token goes straight to Supabase with
  /// `signInWithIdToken`, which creates the session. A random nonce, hashed
  /// for Google and raw for Supabase, stops a captured token being replayed.
  ///
  /// Needs, in the Google Cloud project that owns [Env.googleWebClientId], an
  /// **Android** OAuth client for `in.akhandbharatacademy.app` with the
  /// SHA-1 of the signing key (docs/RELEASE.md). Without it Google answers
  /// with a configuration error, reported here as one.
  ///
  /// `cancelled` is true when the student closed the sheet, so the screen
  /// can stay quiet instead of showing an error.
  static Future<({bool ok, bool cancelled, String? error})>
  signInWithGoogle() async {
    if (!enabled) return (ok: true, cancelled: false, error: null);

    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final google = GoogleSignIn.instance;
      // The nonce is fixed at initialize, so re-initialise for every attempt.
      if (_googleReady) await google.signOut();
      await google.initialize(
        serverClientId: Env.googleWebClientId,
        nonce: hashedNonce,
      );
      _googleReady = true;

      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return (
          ok: false,
          cancelled: false,
          error: 'Google did not return an ID token.',
        );
      }

      await Api.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        nonce: rawNonce,
      );
      return (ok: true, cancelled: false, error: null);
    } on GoogleSignInException catch (e) {
      return switch (e.code) {
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted => (
          ok: false,
          cancelled: true,
          error: null,
        ),
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError => (
          ok: false,
          cancelled: false,
          error:
              'Google sign-in is not set up for this app build yet. '
              'Please use your mobile number for now.',
        ),
        _ => (
          ok: false,
          cancelled: false,
          error: e.description ?? 'Google sign-in failed.',
        ),
      };
    } on AuthException catch (e) {
      return (ok: false, cancelled: false, error: e.message);
    } catch (e) {
      return (ok: false, cancelled: false, error: e.toString());
    }
  }

  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Signs in as the seeded demo student with email + password, skipping the
  /// SMS OTP. Returns ok without doing anything on mock data, where the caller
  /// fakes a session itself.
  ///
  /// Debug builds only, deliberately: this is a way around authentication, and
  /// a release build on a student's phone must not carry one.
  static Future<({bool ok, String? error})> quickLogin() async {
    if (!enabled) return (ok: true, error: null);

    if (!kDebugMode) {
      return (ok: false, error: 'Quick login is off in release builds.');
    }
    if (!Env.hasDemoLogin) {
      return (
        ok: false,
        error: 'Build with --dart-define=DEMO_EMAIL and DEMO_PASSWORD first.',
      );
    }

    try {
      await Api.auth.signInWithPassword(
        email: Env.demoEmail,
        password: Env.demoPassword,
      );
      return (ok: true, error: null);
    } on AuthException catch (e) {
      return (ok: false, error: e.message);
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  static Future<void> signOut() async {
    if (!enabled) return;
    await Api.auth.signOut();
    // Forget the Google account too, so the next sign-in offers the picker
    // instead of silently reusing it.
    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }
}
