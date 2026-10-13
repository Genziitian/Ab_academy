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
  bool _sending = false;

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

  Future<void> _submit() async {
    if (!_canSubmit || _sending) return;
    setState(() => _sending = true);
    try {
      final id = await ref
          .read(ticketsProvider.notifier)
          .open(
            subject: _subject.text.trim(),
            category: _category,
            body: _body.text.trim(),
          );
      if (!mounted) return;
      // Replace this screen so Back from the ticket lands on the list.
      context.pushReplacement(Routes.ticket(id));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      showDemoSnack(context, 'Could not send the ticket. Try again.');
    }
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
          const SizedBox(height: 14),
          Text(
            'Our team replies here — you will also get a notification.',
            style: AppText.meta,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: _sending ? 'Sending…' : 'Submit ticket',
            enabled: _canSubmit && !_sending,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
