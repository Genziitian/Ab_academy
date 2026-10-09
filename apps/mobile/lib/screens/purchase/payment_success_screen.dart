import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../utils/format.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const course = MockData.completeBatch;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF6F1),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.science,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check, size: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "You're enrolled 🎉",
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(fontSize: 27),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      textAlign: TextAlign.center,
                      style: AppText.tabular(
                        15,
                        FontWeight.w700,
                        color: AppColors.primary,
                      ).copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your classes, notes and schedule are ready.',
                      textAlign: TextAlign.center,
                      style: AppText.bodyCompact.copyWith(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.card,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _ReceiptRow(label: 'Amount paid', value: formatRupees(course.priceInr)),
                          const SizedBox(height: 12),
                          const _ReceiptRow(label: 'Order ID', value: MockData.orderId),
                          const SizedBox(height: 12),
                          const _ReceiptRow(label: 'First live class', value: 'Today • 6:00 PM'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: Column(
                children: [
                  PrimaryButton(label: 'Start Learning', onPressed: () => context.go(Routes.home)),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Go to My Courses',
                    onPressed: () => context.go(Routes.courses),
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

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.tabular(12.5, FontWeight.w500, color: AppColors.textSubtle)),
        Text(value, style: AppText.tabular(13, FontWeight.w600)),
      ],
    );
  }
}
