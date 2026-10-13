import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import '../home/home_screen.dart';

/// 18 · Updates — announcements and notifications sent from the admin
/// console (Notifications), newest first. Also the Updates tab.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, this.asTab = false});

  /// Shown as a bottom-nav tab: no back button.
  final bool asTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    final unread = items.where((n) => n.isUnread).length;

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
                  if (!asTab) ...[
                    const BackSquareButton(),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: AppText.h1.copyWith(letterSpacing: -0.6),
                        ),
                        Text(
                          unread > 0
                              ? '$unread unread · alerts & announcements'
                              : 'Recent alerts & updates',
                          style: AppText.bodyLg,
                        ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    TextButton(
                      onPressed: () => ref
                          .read(notificationsProvider.notifier)
                          .markAllRead(),
                      child: Text(
                        'Mark all read',
                        style: AppText.tabular(
                          13,
                          FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: items.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(20),
                        children: const [
                          SizedBox(height: 40),
                          EmptyState(
                            icon: LucideIcons.bellOff,
                            title: 'No notifications yet',
                            body:
                                'Class updates, announcements and support replies show up here.',
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                        children: [
                          for (final group in NotificationGroup.values)
                            ..._group(group, items),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _group(NotificationGroup group, List<AppNotification> all) {
    final items = all.where((n) => n.group == group).toList();
    if (items.isEmpty) return const [];
    final label = switch (group) {
      NotificationGroup.today => 'Today',
      NotificationGroup.yesterday => 'Yesterday',
      NotificationGroup.earlier => 'Earlier',
    };
    return [
      GroupHeading(label),
      for (final n in items) ...[
        AnnouncementCard(notification: n),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 10),
    ];
  }
}
