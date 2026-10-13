import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/ticket.dart';
import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'tickets_screen.dart';

/// 21 · Ticket detail — the conversation with support, plus a reply box.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // Replies are written from the admin console; check for new ones while
    // the thread is open.
    Future.microtask(() => ref.read(ticketsProvider.notifier).refresh());
    _poll = Timer.periodic(
      const Duration(seconds: 15),
      (_) => ref.read(ticketsProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(ticketByIdProvider(widget.ticketId));

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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                children: [
                  const BackSquareButton(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ticket == null
                        ? Text('Loading…', style: AppText.meta)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ticket.reference,
                                    style: AppText.mono(
                                      12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TicketStatusPill(status: ticket.status),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                ticket.subject,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.tabular(16, FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            if (ticket == null)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: ticket.messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _Bubble(message: ticket.messages[i]),
                  ),
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
                  onSend: (body) async {
                    try {
                      await ref
                          .read(ticketsProvider.notifier)
                          .reply(widget.ticketId, body);
                    } catch (_) {
                      if (context.mounted) {
                        showDemoSnack(context, 'Could not send. Try again.');
                      }
                    }
                  },
                ),
            ],
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
