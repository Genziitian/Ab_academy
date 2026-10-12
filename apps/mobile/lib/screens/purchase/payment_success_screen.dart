import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// 26 · Payment success.
class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key, this.courseId});

  final String? courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(
      courseByIdProvider(courseId ?? MockData.scienceCrash.id),
    );
    final method = ref.watch(paymentMethodProvider);

    final rows = [
      ('Order ID', MockData.orderId, true),
      ('Amount paid', formatRupees(course.priceInr), false),
      ('Method', method, false),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.successTint,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.successDot,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.check,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text('Payment successful', style: AppText.h3),
                        const SizedBox(height: 6),
                        Text(
                          "You're enrolled in ${course.title}.",
                          textAlign: TextAlign.center,
                          style: AppText.tabular(
                            14,
                            FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.card,
                          ),
                          child: Column(
                            children: [
                              for (final (i, (label, value, mono))
                                  in rows.indexed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: i < rows.length - 1
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: AppColors.fillMutedAlt,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        label,
                                        style: AppText.tabular(
                                          13,
                                          FontWeight.w400,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        value,
                                        style: mono
                                            ? AppText.mono(13)
                                            : AppText.tabular(
                                                13,
                                                FontWeight.w600,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.amberTint,
                            borderRadius: AppRadius.xs,
                          ),
                          child: Text(
                            'Test mode — payments are not connected yet, so nothing was charged.',
                            textAlign: TextAlign.center,
                            style: AppText.meta.copyWith(color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Start learning',
                onPressed: () => context.go(Routes.courses),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Download receipt',
                onPressed: () => showDemoSnack(
                  context,
                  'Receipts arrive once payments go live.',
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
