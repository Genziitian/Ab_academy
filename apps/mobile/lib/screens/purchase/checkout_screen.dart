import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../onboarding/setup_class_screen.dart';

/// 25 · Checkout — order summary and payment method.
///
/// Razorpay is not connected yet, so "Pay" completes a test enrolment and the
/// success screen says so; nothing is charged.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteCourseProvider(courseId)).value;
    final Course course = remote ?? ref.watch(courseByIdProvider(courseId));
    final method = ref.watch(paymentMethodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Checkout',
        actions: [
          Text(
            '🔒 Razorpay',
            style: AppText.tabular(
              12,
              FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: courseGradient(course.thumbnailHue),
                    borderRadius: AppRadius.sm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: AppText.rowTitle),
                      const SizedBox(height: 1),
                      Text(
                        '${course.stream ?? course.subjects.join(' · ')} · ${MockData.planDays} days',
                        style: AppText.meta,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Payment method', style: AppText.cardTitle),
          const SizedBox(height: 12),
          for (final option in MockData.paymentMethods) ...[
            _MethodRow(
              name: option.name,
              subtitle: option.subtitle,
              short: option.short,
              selected: method == option.name,
              onTap: () =>
                  ref.read(paymentMethodProvider.notifier).select(option.name),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          _Summary(course: course),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Pay ${formatRupees(course.priceInr)}',
            onPressed: () =>
                context.go(Routes.paymentSuccess, extra: course.id),
          ),
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.name,
    required this.subtitle,
    required this.short,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String short;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.surface : AppColors.fillMuted,
                borderRadius: AppRadius.xs,
                border: selected ? Border.all(color: AppColors.border) : null,
              ),
              child: Text(
                short,
                style: AppText.tabular(
                  short.length > 3 ? 9 : 11,
                  FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.rowTitle),
                  Text(subtitle, style: AppText.meta),
                ],
              ),
            ),
            RadioDot(selected: selected, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final original = course.originalPriceInr > course.priceInr
        ? course.originalPriceInr
        : course.priceInr;
    final discount = original - course.priceInr;
    final row = AppText.tabular(13, FontWeight.w400, color: AppColors.textBody);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Course price', style: row),
              Text(formatRupees(original), style: row),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount', style: row),
                Text(
                  '− ${formatRupees(discount)}',
                  style: row.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppText.tabular(15, FontWeight.w700)),
              Text(
                formatRupees(course.priceInr),
                style: AppText.tabular(15, FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
