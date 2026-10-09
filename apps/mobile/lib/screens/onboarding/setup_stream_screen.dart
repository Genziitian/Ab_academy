import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import 'setup_class_screen.dart';

const _streams = <(String, String)>[
  ('Science', 'Physics · Chemistry · Biology · Maths'),
  ('Commerce', 'Accountancy · Business Studies · Economics'),
  ('Arts', 'History · Political Science · Geography'),
];

const _mediums = <(String, String)>[('Hindi', 'हिंदी माध्यम'), ('English', 'अंग्रेज़ी माध्यम')];

class SetupStreamScreen extends ConsumerWidget {
  const SetupStreamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SetupProgressHeader(
              step: 'Step 2 of 2',
              trailing: 'Class ${onboarding.classLevel}',
              progress: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose your stream', style: AppText.h2),
                    const SizedBox(height: 20),
                    for (final (name, subtitle) in _streams) ...[
                      _StreamRow(
                        name: name,
                        subtitle: subtitle,
                        selected: onboarding.stream == name,
                        onTap: () => notifier.setStream(name),
                      ),
                      if (name != _streams.last.$1) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 34),
                    Text('Medium of study', style: AppText.h5),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final (name, hindi) in _mediums) ...[
                          if (name != _mediums.first.$1) const SizedBox(width: 12),
                          Expanded(
                            child: _MediumCard(
                              name: '$name Medium',
                              hindi: hindi,
                              selected: onboarding.medium == name,
                              onTap: () => notifier.setMedium(name),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: PrimaryButton(
                label: 'Start learning',
                onPressed: () async {
                  final session = ref.read(sessionProvider.notifier);
                  await session.signIn();
                  await session.applySetup(
                    classLevel: onboarding.classLevel,
                    stream: onboarding.stream,
                    medium: onboarding.medium,
                  );
                  if (!context.mounted) return;
                  context.go(Routes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamRow extends StatelessWidget {
  const _StreamRow({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.tabular(15.5, FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppText.meta.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _MediumCard extends StatelessWidget {
  const _MediumCard({
    required this.name,
    required this.hindi,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String hindi;
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
        height: 84,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: AppText.tabular(15, FontWeight.w700, color: foreground)),
            const SizedBox(height: 5),
            Text(
              hindi,
              style: AppText.devanagari(
                12,
                FontWeight.w500,
                color: foreground.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ring-style radio used by stream rows and payment methods.
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected, this.size = 22, this.thickness = 7});

  final bool selected;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFD2D6E0),
          width: selected ? thickness : 1.5,
        ),
      ),
    );
  }
}
