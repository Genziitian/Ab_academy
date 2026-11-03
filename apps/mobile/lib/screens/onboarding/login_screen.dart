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

  void _phoneComingSoon() =>
      _snack('Sign-in with mobile number is coming soon. Use Google for now.');

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
      _snack(result.error ?? 'Could not send the OTP. Try again.');
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
      _snack(result.error ?? 'Quick login failed.');
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
            ? 'Google sign-in did not complete. Try again or use your mobile number.'
            : result.error ?? 'Google sign-in failed.',
      );
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
          Positioned.fill(child: _AmbientGlow(animation: _ambient)),
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
                          child: Row(
                            children: [
                              const AcademyMark(size: 44),
                              const SizedBox(width: 12),
                              Text('AB Academy', style: AppText.serif(28)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                              Text('Welcome to AB Academy', style: AppText.h2),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in to watch lectures, ask doubts and read notes.',
                                style: AppText.bodyLg,
                              ),
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
                        if (kDebugMode) ...[
                          const SizedBox(height: 10),
                          SecondaryButton(
                            label: 'Quick login (skip OTP)',
                            icon: LucideIcons.zap,
                            onPressed: _quickLogin,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Debug builds only — signs you in as the demo student.',
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
                            child: Text.rich(
                              TextSpan(
                                style: AppText.meta.copyWith(height: 1.5),
                                children: [
                                  const TextSpan(
                                    text: 'By continuing you agree to our ',
                                  ),
                                  TextSpan(
                                    text: 'Terms',
                                    style: AppText.meta.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: AppText.meta.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
                'OR',
                style: AppText.eyebrow(size: 12, letterSpacing: 1),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Mobile number',
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
                  color: Color(0xFFF7F3EC),
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
          label: _busy ? 'Please wait…' : 'Send OTP',
          enabled: _canContinue && !_busy,
          onPressed: _continue,
        ),
      ],
    );
  }
}

/// "Continue with Google", following Google's own button guidance: white
/// surface, hairline border, the four-colour mark at 18pt.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, this.busy = false});

  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.button,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1C1814),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
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
                  busy ? 'Signing in…' : 'Continue with Google',
                  style: AppText.tabular(16.5, FontWeight.w600),
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
      label: 'Sign in with mobile number, coming soon',
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
                  'Sign in with mobile number',
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
                  'COMING SOON',
                  style: AppText.eyebrow(
                    color: AppColors.primary,
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

/// Three soft brand-colour glows drifting slowly behind the screen.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value * 2 * math.pi;
          Widget glow(Color color, double size, double x, double y) => Align(
            alignment: Alignment(x, y),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
          return Stack(
            children: [
              glow(
                AppColors.accent,
                420,
                -1.1 + 0.25 * math.sin(t),
                -1.0 + 0.15 * math.cos(t),
              ),
              glow(
                AppColors.teal,
                360,
                1.2 + 0.2 * math.cos(t),
                0.2 + 0.25 * math.sin(t),
              ),
              glow(
                AppColors.violet,
                320,
                -0.9 + 0.2 * math.sin(t + 1.5),
                1.1 + 0.12 * math.cos(t),
              ),
            ],
          );
        },
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

/// Saffron welcome card: the course promise above two students.
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.ambient});

  /// Drives the photo's slow zoom and the live dot's pulse.
  final Animation<double> ambient;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBDCC2), Color(0xFFF2A86B), AppColors.accent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLASS 12 CRASH COURSE',
                  style: AppText.eyebrow(color: AppColors.primary, size: 11.5),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'The '),
                      TextSpan(
                        text: 'last 90 days',
                        style: AppText.serif(
                          34,
                          italic: true,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(text: ' before your boards.'),
                    ],
                  ),
                  style: AppText.serif(34, height: 1.0),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: AnimatedBuilder(
                  animation: ambient,
                  builder: (context, child) => Transform.scale(
                    scale: 1.04 + 0.04 * math.sin(ambient.value * 2 * math.pi),
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/images/hero-students.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.4),
                    semanticLabel: 'Two students learning with AB Academy',
                  ),
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
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: ambient,
                        builder: (context, _) {
                          // Seven pulses per ambient loop (~2 s each).
                          final pulse =
                              (math.sin(ambient.value * 14 * math.pi) + 1) / 2;
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.liveDot,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liveDot.withValues(
                                    alpha: 0.5 * (1 - pulse),
                                  ),
                                  spreadRadius: 6 * pulse,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Recorded classes + live doubts',
                        style: AppText.tabular(12, FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
