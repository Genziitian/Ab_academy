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
import '../../widgets/buttons.dart';

/// 02 · Login — phone number or Google.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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

  /// Supabase Auth's Google provider.
  ///
  /// Sign-in happens in an external browser, so this cannot navigate as soon
  /// as `signInWithGoogle` returns — at that point the browser has only just
  /// opened and there is no session. We wait for the login-callback deep link
  /// to bring one back, which also means backing out of the browser correctly
  /// leaves the user on this screen instead of on a sessionless home screen.
  Future<void> _googleLogin() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await AuthRepo.signInWithGoogle();
    if (!mounted) return;

    if (!result.ok) {
      setState(() => _busy = false);
      _snack(result.error ?? 'Google sign-in failed.');
      return;
    }

    final signedIn = await AuthRepo.awaitSignIn();
    if (!mounted) return;
    setState(() => _busy = false);

    if (!signedIn) {
      _snack('Google sign-in was cancelled.');
      return;
    }

    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus || _controller.text.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: Image.asset(
                          'assets/images/hero-students.png',
                          fit: BoxFit.cover,
                          semanticLabel:
                              'Students learning with Akhand Bharat Academy',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Log in or sign up', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text(
                      'Use your mobile number or Google account.',
                      style: AppText.bodyLg,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mobile number',
                      style: AppText.tabular(
                        13,
                        FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.sm,
                        border: Border.all(
                          color: focused
                              ? AppColors.primary
                              : AppColors.borderInput,
                          width: focused ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F8FC),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    _GoogleButton(onPressed: _googleLogin),
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
                    Padding(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Continue with Google", following Google's own button guidance: white
/// surface, hairline border, the four-colour mark at 18pt.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.button,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.button,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: AppRadius.button,
            border: Border.all(color: AppColors.borderInput),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CustomPaint(painter: _GoogleMark()),
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: AppText.tabular(16, FontWeight.w600),
              ),
            ],
          ),
        ),
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
