import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'supabase_client.dart';

/// Must be a top-level function: the OS spawns an isolate for it.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Android draws the tray notification itself for messages that carry a
  // `notification` block, so nothing is needed here beyond existing.
}

/// FCM registration and foreground display.
///
/// The token is stored in `device_tokens` and claimed by the signed-in user, so
/// the `send-push` Edge Function can target an audience. Everything here is a
/// no-op when Firebase is not configured, which keeps the app runnable without
/// google-services.json.
abstract final class PushService {
  static const _channel = AndroidNotificationChannel(
    'aba_default',
    'Class and course updates',
    description: 'Live class reminders, new recordings, notes and replies.',
    importance: Importance.high,
  );

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static String? _token;

  static Future<void> init() async {
    if (_ready) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      // No google-services.json / GoogleService-Info.plist in this build.
      debugPrint('PushService: Firebase not configured — push disabled ($e)');
      return;
    }

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('PushService: notifications denied by the user');
        return;
      }

      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      if (!kIsWeb && Platform.isAndroid) {
        await _local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(_channel);
      }

      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
      FirebaseMessaging.onMessage.listen(_showForeground);

      _token = await FirebaseMessaging.instance.getToken();
      await _saveToken(_token);

      // Tokens rotate; keep the row current.
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);

      _ready = true;
    } catch (e) {
      debugPrint('PushService: init failed ($e)');
    }
  }

  /// Android suppresses tray notifications while the app is foregrounded, so
  /// draw one locally.
  static Future<void> _showForeground(RemoteMessage message) async {
    final note = message.notification;
    if (note == null) return;

    await _local.show(
      message.hashCode,
      note.title,
      note.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['deep_link'] as String?,
    );
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null || !Api.isReady) return;

    try {
      final info = await PackageInfo.fromPlatform();
      await Api.client.from('device_tokens').upsert({
        'token': token,
        'platform': kIsWeb
            ? 'web'
            : Platform.isIOS
            ? 'ios'
            : 'android',
        'app_version': '${info.version}+${info.buildNumber}',
        'user_id': Api.currentUserId,
        'is_active': true,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'token');
    } catch (e) {
      debugPrint('PushService: could not save token ($e)');
    }
  }

  /// Called after sign-in, to attach the already-registered token to the user.
  static Future<void> claimTokenForCurrentUser() => _saveToken(_token);

  /// Called on sign-out so the device stops receiving that student's pushes.
  static Future<void> releaseToken() async {
    if (_token == null || !Api.isReady) return;
    try {
      await Api.client
          .from('device_tokens')
          .update({'user_id': null})
          .eq('token', _token!);
    } catch (e) {
      debugPrint('PushService: could not release token ($e)');
    }
  }
}
