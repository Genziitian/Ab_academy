import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';
import '../../utils/format.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseByIdProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 52,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SquareIconButton(
                  icon: LucideIcons.chevronLeft,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    course.batchLabel.replaceAll(' BATCH', ''),
                    style: AppText.eyebrow(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(course.title, style: AppText.h2),
                  const SizedBox(height: 8),
                  Text(
                    'One year of live classes, recordings, notes and tests for every subject — '
                    'taught in Hindi medium by Bihar Board specialists.',
                    style: AppText.body.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  Text('Subjects', style: AppText.tabular(14.5, FontWeight.w700)),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final subject in course.subjects) SubjectTag(subject: subject)],
                  ),
                  const SizedBox(height: 24),

                  Text("What's included", style: AppText.tabular(14.5, FontWeight.w700)),
                  const SizedBox(height: 11),
                  for (final highlight in course.highlights) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.check, size: 17, color: AppColors.science),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            highlight,
                            style: AppText.tabular(
                              13.5,
                              FontWeight.w500,
                              color: const Color(0xFF3A4050),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (highlight != course.highlights.last) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 24),

                  if (course.validityNote != null)
                    AppCard(
                      shadow: null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Validity', style: AppText.tabular(14.5, FontWeight.w700)),
                          const SizedBox(height: 10),
                          Text(
                            course.validityNote!,
                            style: AppText.tabular(
                              13,
                              FontWeight.w400,
                              color: AppColors.textMuted,
                            ).copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.viewPaddingOf(context).bottom + 16,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formatRupees(course.priceInr),
                            style: AppText.tabular(24, FontWeight.w800, letterSpacing: -0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatRupees(course.originalPriceInr),
                            style: AppText.tabular(
                              13,
                              FontWeight.w500,
                              color: AppColors.textFaint,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'One-time • full year',
                        style: AppText.tabular(11.5, FontWeight.w500, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Buy Course',
                      onPressed: () => context.push(Routes.checkout(course.id)),
                    ),
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
