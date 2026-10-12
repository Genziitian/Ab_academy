import 'dart:async';

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

/// 03 · Verify OTP. The six boxes mirror a hidden text field, so the system
/// keyboard and SMS one-time-code autofill both work.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendSeconds = 24;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _verifying = false;
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend(String phone) async {
    _startCountdown();
    final result = await AuthRepo.sendOtp(phone);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.ok
              ? 'OTP resent to +91 $phone'
              : result.error ?? 'Could not resend the OTP.',
        ),
      ),
    );
  }

  /// Verifies the code with Supabase Auth, then loads the real profile. On
  /// mock data AuthRepo returns ok without a network call, so the flow still
  /// reaches the setup screens.
  Future<void> _verify(String phone, String code) async {
    if (_verifying) return;
    setState(() => _verifying = true);

    final result = await AuthRepo.verifyOtp(phone, code);

    if (!mounted) return;
    setState(() => _verifying = false);

    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'That code did not work.')),
      );
      ref.read(onboardingProvider.notifier).clearOtp();
      _controller.clear();
      return;
    }

    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.push(Routes.setupClass);
  }

  String get _countdownLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final phone = onboarding.phone.isEmpty
        ? '98765 43210'
        : _formatted(onboarding.phone);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquareIconButton(
                icon: LucideIcons.arrowLeft,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 28),
              Text('Enter the 6-digit OTP', style: AppText.h2),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: AppText.bodyLg,
                  children: [
                    TextSpan(text: 'Sent to +91 $phone · '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Edit',
                          style: AppText.tabular(
                            15,
                            FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    // Off-screen field that owns the keyboard and autofill.
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 58,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: ref
                              .read(onboardingProvider.notifier)
                              .setOtp,
                          showCursor: false,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < 6; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _OtpCell(otp: onboarding.otp, index: i),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_secondsLeft > 0)
                Text.rich(
                  TextSpan(
                    style: AppText.tabular(
                      14,
                      FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      const TextSpan(text: "Didn't get it? Resend in "),
                      TextSpan(
                        text: _countdownLabel,
                        style: AppText.tabular(14, FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _resend(onboarding.phone),
                  child: Text.rich(
                    TextSpan(
                      style: AppText.tabular(
                        14,
                        FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                      children: [
                        const TextSpan(text: "Didn't get it? "),
                        TextSpan(
                          text: 'Resend OTP',
                          style: AppText.tabular(
                            14,
                            FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: PrimaryButton(
                  label: _verifying ? 'Verifying…' : 'Verify & continue',
                  enabled: onboarding.otpComplete && !_verifying,
                  onPressed: () => _verify(onboarding.phone, onboarding.otp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatted(String digits) => digits.length > 5
      ? '${digits.substring(0, 5)} ${digits.substring(5)}'
      : digits;
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({required this.otp, required this.index});

  final String otp;
  final int index;

  @override
  Widget build(BuildContext context) {
    final digit = index < otp.length ? otp[index] : '';
    final active = index == otp.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.borderInput,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Text(digit, style: AppText.tabular(24, FontWeight.w600)),
    );
  }
}
