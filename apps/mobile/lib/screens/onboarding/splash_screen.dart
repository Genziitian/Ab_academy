import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/academy_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(Routes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AcademyMark(size: 76),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Akhand Bharat Academy',
                        textAlign: TextAlign.center,
                        style: AppText.h1.copyWith(fontSize: 27, height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Learn. Revise. Succeed.',
                      style: AppText.tabular(
                        13.5,
                        FontWeight.w500,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: Column(
                children: [
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primaryTint,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'बिहार बोर्ड • कक्षा 9–12',
                    style: AppText.devanagari(11.5, FontWeight.w500, color: AppColors.textSubtle),
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
