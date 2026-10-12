import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/buttons.dart';
import 'setup_class_screen.dart';

const _streams = <(String, String)>[
  ('Science', 'Physics · Chemistry · Biology · Maths'),
  ('Commerce', 'Accountancy · Business Studies · Economics'),
  ('Arts', 'History · Political Science · Geography'),
];

const _mediums = <(String, String)>[
  ('Hindi', 'हिंदी माध्यम'),
  ('English', 'अंग्रेज़ी माध्यम'),
];

/// 05 · Stream & medium.
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SetupProgressHeader(
              step: 'Step 2 of 2',
              trailing: 'Class ${onboarding.classLevel}',
              progress: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose your stream', style: AppText.h2),
                    const SizedBox(height: 20),
                    for (final (name, subjects) in _streams) ...[
                      SelectableCard(
                        selected: onboarding.stream == name,
                        onTap: () => notifier.setStream(name),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppText.tabular(16, FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subjects,
                                    style: AppText.tabular(
                                      13,
                                      FontWeight.w400,
                                      color: onboarding.stream == name
                                          ? AppColors.textBody
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            RadioDot(selected: onboarding.stream == name),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'Medium of study',
                      style: AppText.tabular(16, FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final (name, hindi) in _mediums) ...[
                          if (name != _mediums.first.$1)
                            const SizedBox(width: 12),
                          Expanded(
                            child: SelectableCard(
                              selected: onboarding.medium == name,
                              onTap: () => notifier.setMedium(name),
                              height: 80,
                              padding: EdgeInsets.zero,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$name Medium',
                                    style: AppText.tabular(
                                      15,
                                      FontWeight.w600,
                                      color: onboarding.medium == name
                                          ? AppColors.primaryPressed
                                          : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hindi,
                                    style: AppText.devanagari(
                                      12,
                                      FontWeight.w400,
                                      color: onboarding.medium == name
                                          ? AppColors.textBody
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
