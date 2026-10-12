/// Build-time configuration, supplied with --dart-define so no key is
/// committed:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// With both empty the app runs on mock data exactly as it did before, which
/// keeps `flutter test` and the route-walk harness working offline.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True when a Supabase project is configured. Everything in
  /// `lib/data/remote/` falls back to `MockData` when this is false.
  static bool get hasBackend =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Seeded demo student used by the quick-login shortcut, so testing the app
  /// does not need a real SMS. Supplied with --dart-define like everything
  /// else here; absent by default, which leaves quick login switched off.
  static const demoEmail = String.fromEnvironment('DEMO_EMAIL');
  static const demoPassword = String.fromEnvironment('DEMO_PASSWORD');

  static bool get hasDemoLogin =>
      demoEmail.isNotEmpty && demoPassword.isNotEmpty;
}
