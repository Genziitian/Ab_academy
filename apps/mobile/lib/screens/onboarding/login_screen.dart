import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/providers/app_providers.dart';
import '../../data/remote/auth_repository.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../config/env.dart';
import '../../widgets/academy_mark.dart';
import '../../widgets/buttons.dart';
import '../../widgets/language_toggle.dart';
import '../../l10n/strings.dart';

/// 02 · Login — phone number or Google.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Plays once: the staggered entrance of every block on the screen.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// Loops slowly: drifting background glows, the photo's breathing zoom and
  /// the live dot's pulse.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "Remove animations": show everything at rest.
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      _ambient.stop();
    } else {
      if (!_intro.isAnimating && _intro.value == 0) _intro.forward();
      if (!_ambient.isAnimating) _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _phoneComingSoon() => _snack(tx.mobileSoonSnack);

  String get _digits => _controller.text.replaceAll(RegExp(r'\D'), '');

  bool get _canContinue => _digits.length == 10;

  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _continue() async {
    if (!_canContinue || _busy) return;

    ref.read(onboardingProvider.notifier).setPhone(_digits);
    setState(() => _busy = true);

    // Sends the real SMS when a backend is configured; a no-op otherwise, so
    // the OTP screen is still reachable on mock data.
    final result = await AuthRepo.sendOtp(_digits);

    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.ok) {
      _snack(result.error ?? tx.otpSendFailed);
      return;
    }
    context.push(Routes.otp);
  }

  /// Development shortcut past the SMS OTP.
  ///
  /// On mock data this just fakes a session. With Supabase configured it signs
  /// in as the seeded demo student for real, so the app runs against live data
  /// and RLS applies exactly as it would for any student.
  Future<void> _quickLogin() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await AuthRepo.quickLogin();
    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.ok) {
      _snack(result.error ?? tx.quickLoginFailed);
      return;
    }

    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.go(Routes.home);
  }

  /// Google sign-in in an in-app account sheet; returns with a session or
  /// an error, never via the browser.
  Future<void> _googleLogin() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await AuthRepo.signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.ok) {
      // Google also reports some setup failures as a cancellation, so say
      // something either way rather than leaving the button doing nothing.
      _snack(
        result.cancelled
            ? tx.googleIncomplete
            : result.error ?? tx.googleFailed,
      );
      return;
    }

    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.go(Routes.home);
  }

  /// Email sign-in for accounts the academy creates (Play review account).
  Future<void> _emailLogin() async {
    if (_busy) return;
    final creds = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _EmailSheet(),
    );
    if (creds == null || !mounted) return;

    setState(() => _busy = true);
    final result = await AuthRepo.signInWithEmail(creds.$1, creds.$2);
    if (!mounted) return;
    setState(() => _busy = false);

    if (!result.ok) {
      _snack(result.error ?? tx.signInFailed);
      return;
    }
    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Reveal(
                          animation: _intro,
                          from: 0,
                          to: 0.4,
                          child: const Row(
                            children: [
                              AcademyMark(size: 48),
                              Spacer(),
                              LanguageToggle(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _Reveal(
                          animation: _intro,
                          from: 0.05,
                          to: 0.5,
                          child: _LoginHero(ambient: _ambient),
                        ),
                        const SizedBox(height: 26),
                        _Reveal(
                          animation: _intro,
                          from: 0.15,
                          to: 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.loginWelcome, style: AppText.h2),
                              const SizedBox(height: 6),
                              Text(tx.loginLead, style: AppText.bodyLg),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Reveal(
                          animation: _intro,
                          from: 0.3,
                          to: 0.75,
                          child: _GoogleButton(
                            onPressed: _googleLogin,
                            busy: _busy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Reveal(
                          animation: _intro,
                          from: 0.4,
                          to: 0.85,
                          child: Env.phoneLogin
                              ? _phoneForm()
                              : _PhoneComingSoon(onTap: _phoneComingSoon),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: _busy ? null : _emailLogin,
                            child: Text(
                              tx.signInWithEmail,
                              style: AppText.meta.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 10),
                          SecondaryButton(
                            label: tx.quickLogin,
                            icon: LucideIcons.zap,
                            onPressed: _quickLogin,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tx.quickLoginNote,
                            textAlign: TextAlign.center,
                            style: AppText.metaSm,
                          ),
                        ],
                        const Spacer(),
                        _Reveal(
                          animation: _intro,
                          from: 0.55,
                          to: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 24, 8, 28),
                            child: Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: AppText.meta.copyWith(height: 1.5),
                                    children: [
                                      TextSpan(text: tx.agreePre),
                                      TextSpan(
                                        text: tx.terms,
                                        style: AppText.meta.copyWith(
                                          color: AppColors.ink,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: tx.and),
                                      TextSpan(
                                        text: tx.privacyPolicy,
                                        style: AppText.meta.copyWith(
                                          color: AppColors.ink,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: '${tx.agreePost}.'),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile number + Send OTP, shown when [Env.phoneLogin] is on.
  Widget _phoneForm() {
    final focused = _focusNode.hasFocus || _controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tx.or,
                style: AppText.eyebrow(size: 12, letterSpacing: 1),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          tx.mobileNumber,
          style: AppText.tabular(13, FontWeight.w500, color: AppColors.ink),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: AppRadius.sm,
            border: Border.all(
              color: focused ? AppColors.primary : AppColors.borderInput,
              width: focused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  border: Border(
                    right: BorderSide(color: AppColors.borderInput),
                  ),
                ),
                child: Text(
                  '+91',
                  style: AppText.tabular(
                    16,
                    FontWeight.w400,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [_PhoneFormatter()],
                    onSubmitted: (_) => _continue(),
                    style: AppText.tabular(16, FontWeight.w400),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      isCollapsed: true,
                      hintText: '98765 43210',
                      hintStyle: AppText.tabular(
                        16,
                        FontWeight.w400,
                        color: AppColors.textFaint,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: _busy ? tx.pleaseWait : tx.sendOtp,
          enabled: _canContinue && !_busy,
          onPressed: _continue,
        ),
      ],
    );
  }
}

/// "Continue with Google", following Google's own button guidance: white
/// surface, hairline border, the four-colour mark at 18pt.
class _EmailSheet extends StatefulWidget {
  const _EmailSheet();

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _ready => _email.text.contains('@') && _password.text.isNotEmpty;

  void _submit() {
    if (!_ready) return;
    Navigator.of(context).pop((_email.text.trim(), _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tx.signInWithEmail, style: AppText.h2),
          const SizedBox(height: 6),
          Text(tx.emailOnlyNote, style: AppText.meta),
          const SizedBox(height: 18),
          TextField(
            controller: _email,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: tx.email),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _hidden,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: tx.password,
              suffixIcon: IconButton(
                icon: Icon(_hidden ? LucideIcons.eye : LucideIcons.eyeOff),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: tx.signIn, enabled: _ready, onPressed: _submit),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, this.busy = false});

  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: AppRadius.button),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.button,
        child: InkWell(
          onTap: busy ? null : onPressed,
          borderRadius: AppRadius.button,
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: AppRadius.button,
              border: Border.all(color: AppColors.borderInput),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                else
                  const SizedBox.square(
                    dimension: 20,
                    child: CustomPaint(painter: _GoogleMark()),
                  ),
                const SizedBox(width: 12),
                Text(
                  busy ? tx.signingIn : tx.continueWithGoogle,
                  style: AppText.tabular(16, FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile-number sign-in, shown but not yet available.
class _PhoneComingSoon extends StatelessWidget {
  const _PhoneComingSoon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tx.signInWithMobileSoon,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.button,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadius.button,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.smartphone,
                size: 20,
                color: AppColors.textSubtle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tx.signInWithMobile,
                  style: AppText.tabular(
                    15.5,
                    FontWeight.w600,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  tx.comingSoonCaps,
                  style: AppText.eyebrow(
                    color: AppColors.textMuted,
                    size: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts [child] in during the [from]–[to] slice of [animation].
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.from,
    required this.to,
    required this.child,
  });

  final Animation<double> animation;
  final double from;
  final double to;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(from, to, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// The Google "G", drawn rather than shipped as an asset.
class _GoogleMark extends CustomPainter {
  const _GoogleMark();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.26;
    final inner = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Four arcs, each in one of Google's brand colours.
    void arc(double startDeg, double sweepDeg, Color color) {
      canvas.drawArc(
        inner,
        startDeg * 3.1415926535 / 180,
        sweepDeg * 3.1415926535 / 180,
        false,
        paint..color = color,
      );
    }

    arc(-18, -72, const Color(0xFFEA4335)); // red, upper right
    arc(-90, -70, const Color(0xFFFBBC05)); // yellow, upper left
    arc(-160, -95, const Color(0xFF34A853)); // green, lower left
    arc(105, -90, const Color(0xFF4285F4)); // blue, lower right

    // The crossbar that closes the G.
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.5,
        stroke * 0.85,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleMark oldDelegate) => false;
}

/// Renders the number as "98765 43210" while keeping raw digits in the value.
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = capped.length > 5
        ? '${capped.substring(0, 5)} ${capped.substring(5)}'
        : capped;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Welcome card: the course promise on white, above two students, in a
/// grey tray — the same calm card as the website.
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.ambient});

  /// Drives the live dot's pulse.
  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.tray,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.rule),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.loginPanelEyebrow, style: AppText.eyebrow()),
                  const SizedBox(height: 10),
                  Text(
                    tx.loginPanelTitle,
                    style: AppText.serif(34, height: 1.05),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/images/hero-students.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.4),
                    semanticLabel: tx.loginPhotoAlt,
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: ambient,
                          builder: (context, _) {
                            final pulse =
                                (math.sin(ambient.value * 14 * math.pi) + 1) /
                                2;
                            return Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.4 * (1 - pulse),
                                    ),
                                    spreadRadius: 5 * pulse,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tx.loginPanelPoint,
                          style: AppText.tabular(12.5, FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
