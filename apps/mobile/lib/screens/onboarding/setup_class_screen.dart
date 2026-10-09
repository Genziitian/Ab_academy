import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

const classHindiNames = <int, String>{
  9: 'कक्षा नौ',
  10: 'कक्षा दस',
  11: 'कक्षा ग्यारह',
  12: 'कक्षा बारह',
};

class SetupClassScreen extends ConsumerWidget {
  const SetupClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).classLevel;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SetupProgressHeader(
              step: 'Step 1 of 2',
              trailing: 'Skip',
              progress: 0.5,
              onTrailingTap: () => context.go(Routes.home),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Which class are you in?', style: AppText.h2),
                    const SizedBox(height: 8),
                    Text("We'll set up your syllabus and timetable", style: AppText.bodyCompact),
                    const SizedBox(height: 28),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 159 / 118,
                      children: [
                        for (final level in [9, 10, 11, 12])
                          _ClassCard(
                            level: level,
                            selected: selected == level,
                            onTap: () => ref.read(onboardingProvider.notifier).setClassLevel(level),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: PrimaryButton(
                label: 'Continue',
                trailingIcon: LucideIcons.arrowRight,
                onPressed: () => context.push(Routes.setupStream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.level, required this.selected, required this.onTap});

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? const Color(0xFF2A2E77) : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x1F3A3F99), blurRadius: 14, offset: Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$level',
              style: AppText.tabular(30, FontWeight.w800, color: foreground, letterSpacing: -1),
            ),
            const SizedBox(height: 5),
            Text(
              'Class',
              style: AppText.tabular(
                13,
                FontWeight.w600,
                color: foreground.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              classHindiNames[level]!,
              style: AppText.devanagari(
                11.5,
                FontWeight.w500,
                color: foreground.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared "Step n of 2" header with the thin progress rail.
class SetupProgressHeader extends StatelessWidget {
  const SetupProgressHeader({
    super.key,
    required this.step,
    required this.trailing,
    required this.progress,
    this.onTrailingTap,
  });

  final String step;
  final String trailing;
  final double progress;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(step, style: AppText.labelStrong),
              GestureDetector(
                onTap: onTrailingTap,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  trailing,
                  style: AppText.labelStrong.copyWith(color: AppColors.textSubtle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(value: progress, height: 5),
        ],
      ),
    );
  }
}
