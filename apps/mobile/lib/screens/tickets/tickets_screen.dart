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
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// Colours per status, used by the list and the detail header.
({Color ink, Color tint}) ticketStatusPalette(TicketStatus status) => switch (status) {
  TicketStatus.open => (ink: AppColors.warningInk, tint: AppColors.warningTint),
  TicketStatus.inProgress => (ink: AppColors.primary, tint: AppColors.primaryTint),
  TicketStatus.resolved => (ink: AppColors.scienceInk, tint: AppColors.scienceTint),
  TicketStatus.closed => (ink: AppColors.textSubtle, tint: AppColors.fillMuted),
};

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
          children: [
            const AppTopBar(title: 'Support tickets'),
            Expanded(
              child: tickets.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: EmptyState(
                        icon: LucideIcons.lifeBuoy,
                        title: 'No tickets yet',
                        body: 'Raise a ticket and our support team will reply here.',
                        action: PrimaryButton(
                          label: 'New ticket',
                          height: 46,
                          expand: false,
                          onPressed: () => context.push(Routes.newTicket),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      itemCount: tickets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _TicketCard(ticket: tickets[index]),
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
              child: PrimaryButton(
                label: 'Raise a new ticket',
                trailingIcon: LucideIcons.plus,
                onPressed: () => context.push(Routes.newTicket),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final palette = ticketStatusPalette(ticket.status);

    return AppCard(
      onTap: () => context.push(Routes.ticket(ticket.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.reference,
                style: AppText.tabular(11.5, FontWeight.w700, color: AppColors.textSubtle),
              ),
              const Spacer(),
              StatusBadge(
                label: ticket.status.label.toUpperCase(),
                color: palette.ink,
                background: palette.tint,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(ticket.subject, style: AppText.cardTitle),
          const SizedBox(height: 6),
          Text('${ticket.category.label} • ${ticket.openedLabel}', style: AppText.metaSm),
          if (ticket.latest != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadius.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    ticket.latest!.fromSupport ? LucideIcons.headphones : LucideIcons.user,
                    size: 14,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      ticket.latest!.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tabular(
                        12.5,
                        FontWeight.w500,
                        color: AppColors.textBodyAlt,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
