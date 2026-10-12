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
import '../../widgets/common.dart';

/// Badge colours per status, used by the list and the detail header.
({Color ink, Color tint}) ticketStatusPalette(
  TicketStatus status,
) => switch (status) {
  TicketStatus.open => (ink: AppColors.primary, tint: AppColors.primaryTint),
  TicketStatus.inProgress => (
    ink: AppColors.warningInk,
    tint: AppColors.amberTint,
  ),
  TicketStatus.resolved => (
    ink: AppColors.success,
    tint: AppColors.successTint,
  ),
  TicketStatus.closed => (ink: AppColors.textMuted, tint: AppColors.fillMuted),
};

/// Uppercase status badge, e.g. "IN PROGRESS".
class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = ticketStatusPalette(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: palette.tint,
        borderRadius: AppRadius.badge,
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppText.badge(color: palette.ink),
      ),
    );
  }
}

/// 20 · Help & support — the student's tickets.
class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Help & support'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          PrimaryButton(
            label: '+ Raise a ticket',
            height: 48,
            onPressed: () => context.push(Routes.newTicket),
          ),
          const SizedBox(height: 12),
          if (tickets.isEmpty)
            const EmptyState(
              icon: LucideIcons.lifeBuoy,
              title: 'No tickets yet',
              body: 'Raise a ticket for payment, video or course problems.',
            ),
          for (final ticket in tickets) ...[
            AppCard(
              padding: const EdgeInsets.all(14),
              onTap: () => context.push(Routes.ticket(ticket.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.reference,
                        style: AppText.mono(11, color: AppColors.textMuted),
                      ),
                      TicketStatusBadge(status: ticket.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(ticket.subject, style: AppText.rowTitle),
                  const SizedBox(height: 3),
                  Text(
                    '${ticket.category.label} · ${ticket.openedLabel}',
                    style: AppText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Text(
            'Mon–Sat, 9 AM – 7 PM IST · We usually reply within 24 hours.',
            style: AppText.meta,
          ),
        ],
      ),
    );
  }
}
