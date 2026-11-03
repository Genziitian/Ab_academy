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

  /// The **web** OAuth client of the Google Cloud project behind Supabase's
  /// Google provider. Native sign-in asks Google for an ID token addressed to
  /// this client, which is the audience Supabase accepts. Client IDs are
  /// public, so a default is fine; override it for another project.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '778886774711-2b8s12ria26qk6nlaods66gpbbplqs00.apps.googleusercontent.com',
  );

  /// The website, shared from More → Share App.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://abacademy.in',
  );

  /// Whether the Notes library is open. Off shows "Notes are coming soon";
  /// build with --dart-define=NOTES_LIVE=true once the PDFs are uploaded.
  /// Notes attached to a lecture open either way.
  static const notesLive = bool.fromEnvironment('NOTES_LIVE');

  /// Mobile-number (OTP) sign-in. Off shows it as "coming soon" and Google is
  /// the only way in; build with --dart-define=PHONE_LOGIN=true once SMS is set
  /// up in Supabase.
  static const phoneLogin = bool.fromEnvironment('PHONE_LOGIN');

  /// Selling courses inside the app. Off by default for Google Play: Play's
  /// Payments policy requires Play Billing for in-app purchases, so students
  /// buy on the website and their courses appear here when they sign in.
  /// Build with --dart-define=IN_APP_PURCHASE=true to show checkout again.
  static const inAppPurchase = bool.fromEnvironment('IN_APP_PURCHASE');

  static bool get hasDemoLogin =>
      demoEmail.isNotEmpty && demoPassword.isNotEmpty;
}
