import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SquareIconButton(
                        icon: LucideIcons.chevronLeft,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                      Text('Notifications', style: AppText.tabular(17, FontWeight.w700)),
                    ],
                  ),
                  TextActionButton(
                    label: 'Mark all read',
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllRead();
                      showDemoSnack(context, 'All notifications marked as read');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  for (final group in NotificationGroup.values) ...[
                    if (notifications.any((n) => n.group == group)) ...[
                      GroupLabel(_groupLabel(group)),
                      const SizedBox(height: 10),
                      for (final item in notifications.where((n) => n.group == group)) ...[
                        _NotificationCard(notification: item),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _groupLabel(NotificationGroup group) => switch (group) {
    NotificationGroup.today => 'TODAY',
    NotificationGroup.yesterday => 'YESTERDAY',
    NotificationGroup.earlier => 'EARLIER',
  };
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: AppRadius.md,
      padding: const EdgeInsets.all(14),
      shadow: null,
      color: notification.isUnread ? const Color(0xFFF7F8FD) : AppColors.surface,
      borderColor: notification.isUnread ? const Color(0xFFE3E5F6) : AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(kind: notification.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppText.cardTitleSm),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppText.tabular(
                    12.5,
                    FontWeight.w400,
                    color: AppColors.textMuted,
                  ).copyWith(height: 1.5),
                ),
                if (notification.actionLabel != null) ...[
                  const SizedBox(height: 10),
                  TextActionButton(
                    label: notification.actionLabel!,
                    onPressed: () => switch (notification.kind) {
                      NotificationKind.live => context.push(Routes.liveLobby),
                      NotificationKind.recording => context.push(Routes.lesson('ch1-l3')),
                      _ => showDemoSnack(context, notification.title),
                    },
                  ),
                ],
              ],
            ),
          ),
          if (notification.timeAgo != null) ...[
            const SizedBox(width: 8),
            Text(
              notification.timeAgo!,
              style: AppText.tabular(11, FontWeight.w400, color: AppColors.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.kind});

  final NotificationKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      NotificationKind.live => Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.liveTint,
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: const LiveDot(size: 8),
      ),
      NotificationKind.test => const IconTile(
        background: AppColors.warningTint,
        icon: LucideIcons.fileText,
        iconColor: AppColors.warningInk,
        iconSize: 17,
        radius: 11,
      ),
      NotificationKind.recording => const IconTile(
        background: AppColors.scienceTint,
        icon: Icons.play_arrow_rounded,
        iconColor: AppColors.science,
        iconSize: 19,
        radius: 11,
      ),
      NotificationKind.notes => IconTile(
        background: AppColors.pdfTint,
        label: 'PDF',
        labelStyle: AppText.badge(
          color: const Color(0xFFC43B3B),
          size: 9,
        ).copyWith(letterSpacing: 0),
        radius: 11,
      ),
      NotificationKind.result => const IconTile(
        background: AppColors.primaryTint,
        icon: LucideIcons.checkCircle,
        iconColor: AppColors.primary,
        iconSize: 17,
        radius: 11,
      ),
    };
  }
}
