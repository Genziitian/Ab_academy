import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// The two classes crash courses run for, with their accent and tagline.
const _classes = <(int, Color, String)>[
  (12, AppColors.primary, 'Board 2027 crash courses'),
  (11, AppColors.violet, 'Build a strong base for Class 12'),
];

/// 04 · Choose class.
class SetupClassScreen extends ConsumerWidget {
  const SetupClassScreen({super.key, this.editing = false});

  /// Opened from Profile to change class and stream rather than at sign-up.
  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).classLevel;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (editing)
              const AppTopBar(title: 'Class & stream')
            else
              const SetupProgressHeader(
                step: 'Step 1 of 2',
                trailing: 'Bihar Board',
                progress: 0.5,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Which class are you in?', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text(
                      "We'll show crash courses for your class.",
                      style: AppText.bodyLg,
                    ),
                    const SizedBox(height: 28),
                    for (final (level, accent, tagline) in _classes) ...[
                      _ClassCard(
                        level: level,
                        accent: accent,
                        tagline: tagline,
                        selected: selected == level,
                        onTap: () => ref
                            .read(onboardingProvider.notifier)
                            .setClassLevel(level),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: () => context.push(
                  editing ? Routes.setupStreamEdit : Routes.setupStream,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.level,
    required this.accent,
    required this.tagline,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final Color accent;
  final String tagline;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SelectableCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              '$level',
              style: AppText.tabular(36, FontWeight.w700, color: accent),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class $level', style: AppText.cardTitleLg),
                const SizedBox(height: 2),
                Text(
                  tagline,
                  style: AppText.tabular(
                    13,
                    FontWeight.w400,
                    color: selected ? AppColors.textBody : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          RadioDot(selected: selected),
        ],
      ),
    );
  }
}

/// Bordered option card — blue-tinted with a heavier border when selected.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.height,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderStrong,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Radio indicator: a thick blue ring when selected, a hairline circle when not.
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected, this.size = 22});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderRadio,
          width: selected ? size * 0.32 : 1.5,
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
  });

  final String step;
  final String trailing;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(step, style: AppText.label),
              Text(trailing, style: AppText.label),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: progress, height: 4),
        ],
      ),
    );
  }
}
