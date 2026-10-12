import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/ticket.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

const _categories = [
  TicketCategory.payment,
  TicketCategory.technical,
  TicketCategory.content,
  TicketCategory.other,
];

/// 22 · Raise a ticket.
class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  TicketCategory _category = TicketCategory.payment;

  @override
  void initState() {
    super.initState();
    _subject.addListener(() => setState(() {}));
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _subject.text.trim().isNotEmpty && _body.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    final id = ref
        .read(ticketsProvider.notifier)
        .open(
          subject: _subject.text.trim(),
          category: _category,
          body: _body.text.trim(),
        );
    // Replace this screen so Back from the ticket lands on the list.
    context.pushReplacement(Routes.ticket(id));
  }

  @override
  Widget build(BuildContext context) {
    final label = AppText.tabular(13, FontWeight.w500);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppTopBar(title: 'Raise a ticket', closeIcon: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Category', style: label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _categories)
                ChoiceChipPill(
                  label: c.label,
                  selected: _category == c,
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Subject', style: label),
          const SizedBox(height: 6),
          AppTextField(
            controller: _subject,
            hint: 'Briefly describe the issue',
          ),
          const SizedBox(height: 18),
          Text('Details', style: label),
          const SizedBox(height: 6),
          AppTextField(
            controller: _body,
            hint: 'Include order ID, course name or screenshots where helpful',
            maxLines: 7,
            minLines: 5,
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () =>
                showDemoSnack(context, 'Screenshot upload is coming soon.'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.primaryTintBorder),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(
              '+ Attach screenshot',
              style: AppText.tabular(
                14,
                FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Submit ticket',
            enabled: _canSubmit,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
