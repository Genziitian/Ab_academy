import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/ticket.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';

/// 21 · Support — the student's tickets; the academy replies from the admin
/// console (Tickets) and the thread updates here.
class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  const BackSquareButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support',
                          style: AppText.h1.copyWith(letterSpacing: -0.6),
                        ),
                        Text(
                          'We usually reply within a day',
                          style: AppText.bodyLg,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(ticketsProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  children: [
                    SoftCard(
                      onTap: () => context.push(Routes.newTicket),
                      child: Row(
                        children: [
                          GradientIcon(
                            icon: LucideIcons.messageSquarePlus,
                            gradient: AppGradients.sky,
                            size: 54,
                            iconSize: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raise a new ticket',
                                  style: AppText.tabular(17, FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Payments, course content, the app or anything else',
                                  style: AppText.meta,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronRight,
                            color: AppColors.textSubtle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const GroupHeading('Your tickets'),
                    if (tickets.isEmpty)
                      const EmptyState(
                        icon: LucideIcons.lifeBuoy,
                        title: 'No tickets yet',
                        body: 'Raise one and our team will reply here.',
                      )
                    else
                      for (final t in tickets) ...[
                        _TicketCard(ticket: t),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketStatusPill extends StatelessWidget {
  const TicketStatusPill({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TicketStatus.open => (AppColors.warningTint, AppColors.warning),
      TicketStatus.inProgress => (AppColors.primaryTint, AppColors.primary),
      TicketStatus.resolved => (AppColors.successTint, AppColors.success),
      TicketStatus.closed => (AppColors.fillMuted, AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Text(
        status.label.toUpperCase(),
        style: AppText.badge(color: fg, size: 10),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final latest = ticket.latest;
    final awaitingYou = latest?.fromSupport ?? false;
    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push(Routes.ticket(ticket.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.reference,
                style: AppText.mono(12, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              TicketStatusPill(status: ticket.status),
              const Spacer(),
              Text(latest?.timeLabel ?? '', style: AppText.meta),
            ],
          ),
          const SizedBox(height: 8),
          Text(ticket.subject, style: AppText.tabular(16, FontWeight.w600)),
          if (latest != null) ...[
            const SizedBox(height: 6),
            Text(
              '${latest.fromSupport ? '${latest.authorName ?? 'Support'}: ' : 'You: '}${latest.body}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.tabular(
                14,
                awaitingYou ? FontWeight.w600 : FontWeight.w400,
                color: awaitingYou ? AppColors.ink : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
