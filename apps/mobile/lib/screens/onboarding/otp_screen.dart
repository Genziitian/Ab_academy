import 'dart:async';

import 'package:flutter/material.dart';
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

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  bool _verifying = false;

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
      return;
    }

    await ref.read(sessionProvider.notifier).signIn();
    if (!mounted) return;
    context.push(Routes.setupClass);
  }

  static const _resendSeconds = 24;

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

  String get _countdownLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final phone = onboarding.phone.isEmpty ? '98765 43210' : _formatted(onboarding.phone);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SquareIconButton(
                    icon: LucideIcons.chevronLeft,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verify your number', style: AppText.h2),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: AppText.bodyCompact,
                        children: [
                          const TextSpan(text: 'Enter the 6-digit code sent to '),
                          TextSpan(
                            text: '+91 $phone',
                            style: AppText.bodyCompact.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        for (var i = 0; i < 6; i++) ...[
                          if (i > 0) const SizedBox(width: 9),
                          Expanded(
                            child: _OtpCell(otp: onboarding.otp, index: i),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_secondsLeft > 0)
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                style: AppText.tabular(
                                  13,
                                  FontWeight.w400,
                                  color: AppColors.textSubtle,
                                ),
                                children: [
                                  const TextSpan(text: 'Resend code in '),
                                  TextSpan(
                                    text: _countdownLabel,
                                    style: AppText.tabular(
                                      13,
                                      FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              'Didn\'t get the code?',
                              overflow: TextOverflow.ellipsis,
                              style: AppText.tabular(
                                13,
                                FontWeight.w400,
                                color: AppColors.textSubtle,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _secondsLeft == 0 ? () => _resend(phone) : null,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            'Resend OTP',
                            style: AppText.tabular(
                              13,
                              FontWeight.w700,
                              color: _secondsLeft == 0 ? AppColors.primary : AppColors.textDisabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: _verifying ? 'Verifying…' : 'Verify & Continue',
                      enabled: onboarding.otpComplete && !_verifying,
                      onPressed: () => _verify(onboarding.phone, onboarding.otp),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _Keypad(onDigit: notifier.pressKey, onBackspace: notifier.backspace),
          ],
        ),
      ),
    );
  }

  String _formatted(String digits) =>
      digits.length > 5 ? '${digits.substring(0, 5)} ${digits.substring(5)}' : digits;
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({required this.otp, required this.index});

  final String otp;
  final int index;

  @override
  Widget build(BuildContext context) {
    final digit = index < otp.length ? otp[index] : '';
    final filled = digit.isNotEmpty;
    final active = index == otp.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.primaryTint : AppColors.surface,
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: filled || active ? AppColors.primary : AppColors.borderInput,
          width: filled || active ? 1.5 : 1,
        ),
        boxShadow: active && !filled
            ? const [BoxShadow(color: AppColors.primaryTint, spreadRadius: 4, blurRadius: 0)]
            : null,
      ),
      child: Text(digit, style: AppText.tabular(22, FontWeight.w700)),
    );
  }
}

/// The design uses its own keypad rather than the OS keyboard.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fillMuted,
        border: Border(top: BorderSide(color: Color(0xFFE4E6ED))),
      ),
      padding: EdgeInsets.fromLTRB(6, 10, 6, safeBottom > 0 ? safeBottom + 8 : 26),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 126 / 52,
        children: [
          for (final key in _keys)
            if (key.isEmpty)
              const SizedBox.shrink()
            else
              _Key(
                label: key == 'del' ? '⌫' : key,
                onTap: () => key == 'del' ? onBackspace() : onDigit(key),
              ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.xs,
      elevation: 0.5,
      shadowColor: const Color(0x1214161C),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xs,
        child: Center(child: Text(label, style: AppText.tabular(22, FontWeight.w600))),
      ),
    );
  }
}
