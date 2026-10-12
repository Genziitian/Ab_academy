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
import '../../widgets/common.dart';

const _groupLabels = {
  NotificationGroup.today: 'TODAY',
  NotificationGroup.yesterday: 'YESTERDAY',
  NotificationGroup.earlier: 'EARLIER',
};

/// 18 · Notifications, grouped by day; unread rows are tinted.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.any((n) => n.isUnread);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: unread
                ? () => ref.read(notificationsProvider.notifier).markAllRead()
                : null,
            child: Text(
              'Mark all read',
              style: AppText.tabular(
                13,
                FontWeight.w600,
                color: unread ? AppColors.primary : AppColors.textSubtle,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyState(
                icon: LucideIcons.bellOff,
                title: 'All caught up',
                body:
                    'Class reminders, new notes and results will show up here.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                for (final group in NotificationGroup.values)
                  if (notifications.any((n) => n.group == group)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        _groupLabels[group]!,
                        style: AppText.eyebrow(letterSpacing: 0.9),
                      ),
                    ),
                    ListCard(
                      children: [
                        for (final n in notifications.where(
                          (n) => n.group == group,
                        ))
                          _NotificationRow(notification: n),
                      ],
                    ),
                  ],
              ],
            ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final AppNotification notification;

  void _act(BuildContext context) => switch (notification.kind) {
    NotificationKind.live => context.push(Routes.liveRoom),
    NotificationKind.recording => context.push(Routes.lesson('ch1-l3')),
    NotificationKind.notes => context.go(Routes.notes),
    NotificationKind.test ||
    NotificationKind.result => context.push(Routes.calendar),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, glyph) = switch (notification.kind) {
      NotificationKind.live => (AppColors.liveTint, AppColors.liveInk, '●'),
      NotificationKind.test => (AppColors.amberTint, AppColors.warningInk, '✎'),
      NotificationKind.recording => (
        AppColors.primaryTint,
        AppColors.primary,
        '▶',
      ),
      NotificationKind.notes => (AppColors.mathsTint, AppColors.maths, '≡'),
      NotificationKind.result => (
        AppColors.successTint,
        AppColors.success,
        '✓',
      ),
    };

    return InkWell(
      onTap: () => _act(context),
      child: Container(
        color: notification.isUnread
            ? AppColors.surfaceMuted
            : AppColors.surface,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, borderRadius: AppRadius.xs),
              child: Text(
                glyph,
                style: AppText.tabular(13, FontWeight.w700, color: fg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppText.rowTitle,
                        ),
                      ),
                      if (notification.timeAgo != null)
                        Text(
                          notification.timeAgo!,
                          style: AppText.tabular(
                            11,
                            FontWeight.w400,
                            color: AppColors.textSubtle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                      color: AppColors.textBody,
                    ),
                  ),
                  if (notification.actionLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.actionLabel!,
                      style: AppText.tabular(
                        12,
                        FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
