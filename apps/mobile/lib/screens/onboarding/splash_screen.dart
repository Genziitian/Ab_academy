import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/academy_mark.dart';

/// 01 · Splash — white mark on brand blue.
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AcademyMark(size: 84, inverted: true),
                        const SizedBox(height: 24),
                        Text(
                          'Akhand Bharat Academy',
                          textAlign: TextAlign.center,
                          style: AppText.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Class 11 & 12 Crash Courses',
                          style: AppText.tabular(
                            15,
                            FontWeight.w400,
                            color: const Color(0xFFDBE6FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Text(
                  'आज शुरू करें — कल का आत्मविश्वास बनाएँ।',
                  textAlign: TextAlign.center,
                  style: AppText.devanagari(
                    14,
                    FontWeight.w400,
                    color: const Color(0xFFC7D6FF),
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
