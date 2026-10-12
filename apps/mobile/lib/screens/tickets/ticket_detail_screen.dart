import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/ticket.dart';
import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import 'tickets_screen.dart';

/// 21 · Ticket detail — the conversation with support, plus a reply box.
class TicketDetailScreen extends ConsumerWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticket = ref.watch(ticketByIdProvider(ticketId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        ticket.reference,
                        style: AppText.mono(12, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 10),
                      TicketStatusBadge(status: ticket.status),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      ticket.subject,
                      style: AppText.tabular(16, FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                itemCount: ticket.messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _Bubble(message: ticket.messages[i]),
              ),
            ),
            if (ticket.isClosed)
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Text(
                  'This ticket is ${ticket.status.label.toLowerCase()}. Raise a new one if the problem comes back.',
                  textAlign: TextAlign.center,
                  style: AppText.meta,
                ),
              )
            else
              MessageComposer(
                hint: 'Write a reply…',
                onSend: (body) =>
                    ref.read(ticketsProvider.notifier).reply(ticketId, body),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = !message.fromSupport;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : AppColors.surface,
            border: mine ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(mine ? 12 : 2),
              bottomRight: Radius.circular(mine ? 2 : 12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mine) ...[
                Text(
                  message.authorName ?? 'Support',
                  style: AppText.tabular(
                    11,
                    FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                message.body,
                style: AppText.tabular(
                  13,
                  FontWeight.w400,
                  color: mine ? Colors.white : AppColors.ink,
                ).copyWith(height: 1.55),
              ),
              const SizedBox(height: 6),
              Text(
                message.timeLabel,
                style: AppText.tabular(
                  11,
                  FontWeight.w400,
                  color: mine ? const Color(0xFFC7D6FF) : AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
