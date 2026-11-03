import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons/lucide_icons.dart';

import '../../config/academy.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../data/remote/payment_service.dart';
import '../../data/remote/repositories.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/brand_art.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import '../onboarding/setup_class_screen.dart';

/// 25 · Checkout — the course, what it includes, how to pay, the total.
///
/// With Supabase configured, "Pay" sells the course for real through
/// [PaymentService] (Razorpay). On mock data it completes a test enrolment and
/// the success screen says nothing was charged.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _payments = PaymentService();
  bool _paying = false;

  String get courseId => widget.courseId;

  @override
  void dispose() {
    _payments.dispose();
    super.dispose();
  }

  Future<void> _pay(Course course, String method) async {
    if (_paying) return;

    if (!ref.read(hasBackendProvider)) {
      context.go(
        Routes.paymentSuccess,
        extra: PaymentReceipt(
          courseId: course.id,
          orderId: MockData.orderId,
          amountInr: course.priceInr,
          method: method,
          testMode: true,
        ),
      );
      return;
    }

    setState(() => _paying = true);
    try {
      final receipt = await _payments.buy(
        courseId: course.id,
        methodLabel: method,
      );
      // The new enrolment shows up in My courses and the store.
      ref.invalidate(remoteMyCoursesProvider);
      ref.invalidate(remoteCatalogProvider(null));
      if (!mounted) return;
      context.go(Routes.paymentSuccess, extra: receipt);
    } on CheckoutException catch (e) {
      if (mounted) showDemoSnack(context, e.message);
    } catch (_) {
      if (mounted) {
        showDemoSnack(context, 'Payment could not be completed. Try again.');
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remote = ref.watch(remoteCourseProvider(courseId)).value;
    final Course course = remote ?? ref.watch(courseByIdProvider(courseId));
    final method = ref.watch(paymentMethodProvider);
    final selected = _methods.any((m) => m.name == method)
        ? method
        : _methods.first.name;
    final teacher = course.teachers.isEmpty
        ? 'Ajit Sir'
        : course.teachers.first.displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Checkout',
        actions: [
          const Icon(LucideIcons.lock, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Secure',
            style: AppText.tabular(
              13,
              FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            'COMPLETE YOUR ENROLMENT',
            style: AppText.eyebrow(color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          // The course being bought.
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.md,
                        child: SizedBox(
                          width: 76,
                          height: 76,
                          child: CourseThumbnail(
                            url: courseArtwork(course),
                            hue: course.thumbnailHue,
                            shade: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CLASS ${course.classLevel} · ${course.board.toUpperCase()}',
                              style: AppText.eyebrow(
                                color: AppColors.primary,
                                size: 10,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(course.title, style: AppText.cardTitleLg),
                            const SizedBox(height: 3),
                            Text('with $teacher', style: AppText.meta),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    children: [
                      for (final item in [
                        'Recorded classes — watch anytime',
                        'Live doubt sessions with $teacher',
                        'On the app and the website',
                        'Access until 31 March 2027',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.checkCircle2,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item, style: AppText.body)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Pay with', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          for (final option in _methods) ...[
            _MethodRow(
              icon: option.icon,
              name: option.name,
              subtitle: option.subtitle,
              selected: selected == option.name,
              onTap: () =>
                  ref.read(paymentMethodProvider.notifier).select(option.name),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          _Summary(course: course),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                size: 16,
                color: AppColors.textSubtle,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payments are processed securely by Razorpay — we never see '
                  'your card or UPI details. 7-day refund if you have watched '
                  '3 lectures or fewer. Questions? ${Academy.email}',
                  style: AppText.meta.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppText.meta),
                  Text(
                    formatRupees(course.priceInr),
                    style: AppText.serif(30, height: 1.0),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: PrimaryButton(
                  label: _paying ? 'Opening payment…' : 'Pay securely',
                  enabled: !_paying,
                  onPressed: () => _pay(course, selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _methods = [
  (
    name: 'UPI',
    subtitle: 'Google Pay, PhonePe, Paytm or any UPI app',
    icon: LucideIcons.smartphone,
  ),
  (
    name: 'Card / Net banking',
    subtitle: 'Visa, Mastercard, RuPay and all major banks',
    icon: LucideIcons.creditCard,
  ),
];

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              TintIcon(icon: icon, color: AppColors.primary, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.cardTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.meta),
                  ],
                ),
              ),
              RadioDot(selected: selected, size: 20),
            ],
          ),
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
    final row = AppText.tabular(14, FontWeight.w400, color: AppColors.textBody);

    return SoftCard(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppText.tabular(16, FontWeight.w700)),
              Text(
                formatRupees(course.priceInr),
                style: AppText.serif(30, height: 1.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
