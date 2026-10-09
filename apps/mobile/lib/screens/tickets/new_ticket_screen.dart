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

  bool get _canSubmit => _subject.text.trim().isNotEmpty && _body.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    final id = ref
        .read(ticketsProvider.notifier)
        .open(subject: _subject.text.trim(), category: _category, body: _body.text.trim());
    // Replace this screen so Back from the ticket lands on the list.
    context.pushReplacement(Routes.ticket(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'New ticket'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Text('What is this about?', style: AppText.cardTitle),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in TicketCategory.values)
                        FilterChipPill(
                          label: category.label,
                          selected: _category == category,
                          onTap: () => setState(() => _category = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Subject', style: AppText.cardTitle),
                  const SizedBox(height: 10),
                  AppTextField(controller: _subject, hint: 'Summarise the problem in one line'),
                  const SizedBox(height: 22),
                  Text('Details', style: AppText.cardTitle),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _body,
                    hint: 'Tell us what happened, and what you expected instead.',
                    maxLines: 8,
                    minLines: 5,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Our support team replies within one working day.',
                    style: AppText.metaSm.copyWith(height: 1.5),
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
              child: PrimaryButton(label: 'Submit ticket', enabled: _canSubmit, onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
