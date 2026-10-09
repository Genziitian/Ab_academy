import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/ticket.dart';
import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';
import '../lessons/lecture_screen.dart';
import 'tickets_screen.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    ref.read(ticketsProvider.notifier).reply(widget.ticketId, body);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(ticketByIdProvider(widget.ticketId));
    final palette = ticketStatusPalette(ticket.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: ticket.reference, subtitle: ticket.category.label),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  AppCard(
                    shadow: null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(ticket.subject, style: AppText.cardTitle)),
                            const SizedBox(width: 10),
                            StatusBadge(
                              label: ticket.status.label.toUpperCase(),
                              color: palette.ink,
                              background: palette.tint,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(ticket.openedLabel, style: AppText.metaSm),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final message in ticket.messages) ...[
                    _TicketMessageTile(message: message),
                    const SizedBox(height: 14),
                  ],
                  if (ticket.isClosed) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.fillMutedAlt,
                        borderRadius: AppRadius.sm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.checkCircle,
                            size: 16,
                            color: AppColors.scienceInk,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'This ticket is ${ticket.status.label.toLowerCase()}. '
                              'Reply below to reopen it.',
                              style: AppText.tabular(
                                12,
                                FontWeight.w500,
                                color: AppColors.textMuted,
                              ).copyWith(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            MessageComposer(controller: _controller, hint: 'Write a reply…', onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _TicketMessageTile extends StatelessWidget {
  const _TicketMessageTile({required this.message});

  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final fromSupport = message.fromSupport;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fromSupport ? AppColors.primaryTint : AppColors.fillMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            fromSupport ? LucideIcons.headphones : LucideIcons.user,
            size: 15,
            color: fromSupport ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      message.authorName ?? 'You',
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tabular(12.5, FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(message.timeLabel, style: AppText.metaSm.copyWith(fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: fromSupport ? const Color(0xFFF5F6FD) : AppColors.surface,
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: fromSupport ? const Color(0xFFE3E5F6) : AppColors.border,
                  ),
                ),
                child: Text(
                  message.body,
                  style: AppText.tabular(
                    13,
                    FontWeight.w400,
                    color: AppColors.textBodyAlt,
                  ).copyWith(height: 1.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
