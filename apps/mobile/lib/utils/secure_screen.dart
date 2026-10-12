import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Blocks screenshots and screen recording while paid video is on screen.
///
/// Android only (FLAG_SECURE, see MainActivity.kt). iOS has no equivalent
/// switch; the player's moving watermark is the deterrent there.
abstract final class SecureScreen {
  static const _channel = MethodChannel('academy/secure_screen');

  /// QA switch for taking screenshots of the player:
  /// `--dart-define=ALLOW_SCREENSHOTS=true`. Off unless passed explicitly.
  static const _allowScreenshots = bool.fromEnvironment('ALLOW_SCREENSHOTS');

  static Future<void> enable() => _call('enable');

  static Future<void> disable() => _call('disable');

  static Future<void> _call(String method) async {
    if (_allowScreenshots) return;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Widget tests and other hosts without the channel.
    }
  }
}
