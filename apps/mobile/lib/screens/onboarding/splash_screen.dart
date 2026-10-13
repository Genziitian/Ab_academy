import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../data/remote/auth_repository.dart';

import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 01 · Splash — white mark on brand blue.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _route);
  }

  /// A session saved from an earlier launch goes straight to Home; only a
  /// signed-out student sees the login screen.
  Future<void> _route() async {
    if (AuthRepo.enabled && AuthRepo.isSignedIn) {
      await ref.read(sessionProvider.notifier).signIn();
      if (mounted) context.go(Routes.home);
      return;
    }
    if (mounted) context.go(Routes.login);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE6F2FD);
    const navy = Color(0xFF14285C);
    const saffron = Color(0xFFE07A1F);
    const gold = Color(0xFFC9A15A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // Soft decorative circle in the corner.
            Positioned(
              right: -90,
              bottom: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE6F7).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: navy.withValues(alpha: 0.22),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text.rich(
                              const TextSpan(
                                text: 'Akhand Bharat ',
                                style: TextStyle(color: navy),
                                children: [
                                  TextSpan(
                                    text: 'Academy',
                                    style: TextStyle(color: saffron),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: AppText.tabular(
                                30,
                                FontWeight.w600,
                              ).copyWith(letterSpacing: -0.4),
                            ),
                            const SizedBox(height: 18),
                            Container(width: 52, height: 3, color: gold),
                            const SizedBox(height: 18),
                            Text(
                              'LEARN  •  LEAD  •  BUILD',
                              textAlign: TextAlign.center,
                              style: AppText.tabular(
                                14,
                                FontWeight.w500,
                                color: const Color(0xFF5E6B80),
                              ).copyWith(letterSpacing: 3.2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'A STRONGER BHARAT',
                              textAlign: TextAlign.center,
                              style: AppText.tabular(
                                14,
                                FontWeight.w500,
                                color: const Color(0xFF5E6B80),
                              ).copyWith(letterSpacing: 3.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: _LoadingDots(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three dots with the active one sliding along while the app starts.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final active = (_c.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == active ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == active
                      ? AppColors.primary
                      : const Color(0xFFB9C7D9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        );
      },
    );
  }
}
