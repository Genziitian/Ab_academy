import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../onboarding/setup_stream_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseByIdProvider(courseId));
    final method = ref.watch(paymentMethodProvider);
    final student = ref.watch(studentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SquareIconButton(icon: LucideIcons.chevronLeft, onPressed: () => context.pop()),
                  const SizedBox(width: 12),
                  Text('Complete Payment', style: AppText.tabular(17, FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  AppCard(
                    shadow: null,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.title, style: AppText.cardTitle),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${course.board} • 2027 • ${student.medium} Medium',
                                    style: AppText.meta,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              formatRupees(course.originalPriceInr),
                              style: AppText.tabular(15, FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.dividerSoft),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount applied',
                              style: AppText.tabular(
                                12.5,
                                FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '− ${formatRupees(MockData.discountInr)}',
                              style: AppText.tabular(
                                12.5,
                                FontWeight.w600,
                                color: AppColors.scienceInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total payable', style: AppText.cardTitleSm),
                            Text(
                              formatRupees(course.priceInr),
                              style: AppText.tabular(18, FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(13)),
                            border: Border.all(color: const Color(0xFFC9CDD9)),
                          ),
                          child: Text(
                            'Have a coupon code?',
                            style: AppText.tabular(
                              13,
                              FontWeight.w500,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      GestureDetector(
                        onTap: () => showDemoSnack(context, 'Discount already applied'),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(13)),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Text(
                            'Apply',
                            style: AppText.tabular(13, FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Payment method', style: AppText.tabular(14.5, FontWeight.w700)),
                  const SizedBox(height: 11),
                  for (final option in MockData.paymentMethods) ...[
                    _PaymentMethodRow(
                      option: option,
                      selected: method == option.name,
                      onTap: () => ref.read(paymentMethodProvider.notifier).select(option.name),
                    ),
                    if (option != MockData.paymentMethods.last) const SizedBox(height: 9),
                  ],
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.fillMutedAlt,
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.lock, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Payments are processed securely. Card details are never stored '
                            'on your device.',
                            style: AppText.tabular(
                              11.5,
                              FontWeight.w500,
                              color: AppColors.textMuted,
                            ).copyWith(height: 1.5),
                          ),
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
                14,
                20,
                MediaQuery.viewPaddingOf(context).bottom + 14,
              ),
              child: PrimaryButton(
                label: 'Pay ${formatRupees(course.priceInr)}',
                onPressed: () => context.go(Routes.paymentSuccess),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({required this.option, required this.selected, required this.onTap});

  final PaymentMethodOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (tint, ink) = switch (option.name) {
      'UPI' => (AppColors.primaryTint, AppColors.primary),
      'Google Pay' => (AppColors.mathsTint, AppColors.maths),
      'PhonePe' => (AppColors.englishTint, AppColors.english),
      _ => (AppColors.fillMuted, AppColors.textMuted),
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F8FD) : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            IconTile(
              background: tint,
              label: option.short,
              labelStyle: AppText.tabular(12, FontWeight.w800, color: ink),
              size: 40,
              radius: 12,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name, style: AppText.cardTitleSm),
                  const SizedBox(height: 3),
                  Text(option.subtitle, style: AppText.metaSm),
                ],
              ),
            ),
            RadioDot(selected: selected, size: 20, thickness: 6),
          ],
        ),
      ),
    );
  }
}
