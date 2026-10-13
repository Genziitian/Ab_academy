import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/providers/app_providers.dart';
import '../../data/remote/auth_repository.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ui_kit.dart';

const _bg = Color(0xFFE6F2FD);
const _navy = Color(0xFF14285C);
const _saffron = Color(0xFFE07A1F);
const _gold = Color(0xFFC9A15A);
const _muted = Color(0xFF5E6B80);

/// Each slide stays this long before the next one slides in.
const _slideTime = Duration(milliseconds: 2500);

/// 01 · Opening screen. First launch: three intro slides that advance on
/// their own, with Skip. Later launches: just the logo slide, briefly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _seenKey = 'intro_seen_v1';

  final _pages = PageController();
  Timer? _timer;
  int _page = 0;
  int _count = 1;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    var firstLaunch = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      firstLaunch = !(prefs.getBool(_seenKey) ?? false);
      if (firstLaunch) await prefs.setBool(_seenKey, true);
    } catch (_) {
      // No storage (tests): behave like a returning student.
    }
    if (!mounted) return;
    setState(() => _count = firstLaunch ? 3 : 1);
    _timer = Timer.periodic(
      firstLaunch ? _slideTime : const Duration(milliseconds: 2000),
      (_) => _next(),
    );
  }

  void _next() {
    if (_page + 1 >= _count) {
      _route();
      return;
    }
    _pages.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  /// A session saved from an earlier launch goes straight to Home; only a
  /// signed-out student sees the login screen.
  Future<void> _route() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
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
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = <Widget>[
      const _LogoSlide(),
      const _FeatureSlide(
        icon: LucideIcons.video,
        gradientIndex: 0,
        title: 'Live & recorded classes',
        body:
            'Join live with expert teachers, or watch every lecture again whenever you need it.',
      ),
      const _FeatureSlide(
        icon: LucideIcons.fileText,
        gradientIndex: 1,
        title: 'Notes, tests & doubt support',
        body:
            'Chapter notes, board-pattern practice and answers to your doubts — all in one app.',
      ),
    ].take(_count).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _bg,
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                      child: TextButton(
                        onPressed: _route,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: AppText.tabular(
                            15,
                            FontWeight.w600,
                            color: _navy,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (i) {
                        setState(() => _page = i);
                        // A manual swipe restarts the countdown.
                        _timer?.cancel();
                        _timer = Timer.periodic(_slideTime, (_) => _next());
                      },
                      children: slides,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, top: 12),
                    child: _count > 1
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < _count; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: i == _page ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? AppColors.primary
                                        : const Color(0xFFB9C7D9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          )
                        : const _LoadingDots(),
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

class _LogoSlide extends StatelessWidget {
  const _LogoSlide();

  @override
  Widget build(BuildContext context) {
    final tagline = AppText.tabular(
      14,
      FontWeight.w500,
      color: _muted,
    ).copyWith(letterSpacing: 3.2);
    return Center(
      child: SingleChildScrollView(
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
                    color: _navy.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 28),
            Text.rich(
              const TextSpan(
                text: 'Akhand Bharat ',
                style: TextStyle(color: _navy),
                children: [
                  TextSpan(
                    text: 'Academy',
                    style: TextStyle(color: _saffron),
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
            Container(width: 52, height: 3, color: _gold),
            const SizedBox(height: 18),
            Text(
              'LEARN  •  LEAD  •  BUILD',
              textAlign: TextAlign.center,
              style: tagline,
            ),
            const SizedBox(height: 6),
            Text(
              'A STRONGER BHARAT',
              textAlign: TextAlign.center,
              style: tagline,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({
    required this.icon,
    required this.gradientIndex,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final int gradientIndex;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final gradient = gradientIndex == 0
        ? AppGradients.orange
        : AppGradients.green;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: GradientIcon(
                icon: icon,
                gradient: gradient,
                size: 96,
                iconSize: 44,
                round: true,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.tabular(
                26,
                FontWeight.w600,
                color: _navy,
              ).copyWith(letterSpacing: -0.3),
            ),
            const SizedBox(height: 18),
            Container(width: 52, height: 3, color: _gold),
            const SizedBox(height: 18),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.tabular(
                16,
                FontWeight.w400,
                color: _muted,
              ).copyWith(height: 1.5),
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
