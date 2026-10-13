import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/content.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/course_slider.dart';
import '../../widgets/ui_kit.dart';

/// 06 · Home — greeting, promotional slider, courses, then quick actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final unread = ref.watch(unreadCountProvider);
    // Supabase realtime on `notifications` (a timer on sample data).
    ref.watch(realtimeNotificationProvider);
    final firstName = student.fullName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(bannersProvider);
            ref.invalidate(upcomingSessionsProvider);
            ref.invalidate(remoteCatalogProvider(null));
            ref.invalidate(remoteMyCoursesProvider);
            await ref.read(notificationsProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(Routes.more),
                    child: GradientAvatar(initials: firstName, size: 58),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${_greeting()}, ',
                            children: [
                              TextSpan(
                                text: firstName,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.tabular(20, FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Take a moment to review your progress.',
                          maxLines: 2,
                          style: AppText.tabular(
                            14,
                            FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundIconButton(
                    icon: LucideIcons.bell,
                    badge: unread,
                    onTap: () => context.push(Routes.notifications),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Admin-managed promotional slider (App slider in the console).
              const CourseSlider(padding: EdgeInsets.only(bottom: 26)),
              SectionTitle(
                'Courses for you',
                trailing: ViewAllLink(
                  label: 'See all',
                  onTap: () => context.go(Routes.store),
                ),
              ),
              const SizedBox(height: 14),
              const _HomeCourses(),
              const SizedBox(height: 26),
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: const Color(0x22122046),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Icon(icon, size: 24, color: AppColors.ink),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.liveDot,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                badge > 9 ? '9+' : '$badge',
                style: AppText.tabular(
                  11,
                  FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        LucideIcons.calendarDays,
        'Calendar',
        AppGradients.violet,
        () => context.push(Routes.calendar),
      ),
      (
        LucideIcons.fileText,
        'Notes',
        AppGradients.green,
        () => context.push(Routes.notes),
      ),
      (
        LucideIcons.headphones,
        'Support',
        AppGradients.pink,
        () => context.push(Routes.tickets),
      ),
      (
        LucideIcons.settings,
        'Settings',
        AppGradients.blue,
        () => context.push(Routes.profile),
      ),
    ];
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      child: Row(
        children: [
          for (final (icon, label, gradient, onTap) in actions)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Column(
                  children: [
                    GradientIcon(
                      icon: icon,
                      gradient: gradient,
                      size: 64,
                      iconSize: 28,
                      round: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: AppText.tabular(
                        14,
                        FontWeight.w500,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One announcement / notification: tinted bell, title, body, time.
class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final (icon, color) = switch (n.kind) {
      NotificationKind.live => (LucideIcons.video, const Color(0xFFFF5A1F)),
      NotificationKind.test => (LucideIcons.clipboardCheck, AppColors.warning),
      NotificationKind.recording => (LucideIcons.playCircle, AppColors.teal),
      NotificationKind.notes => (LucideIcons.fileText, AppColors.success),
      NotificationKind.result => (LucideIcons.award, AppColors.primary),
      NotificationKind.support => (LucideIcons.headphones, AppColors.english),
      NotificationKind.announcement => (LucideIcons.bell, AppColors.violet),
    };
    return SoftCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      onTap: () {
        ref.read(notificationsProvider.notifier).markRead(n.id);
        final link = n.deepLink;
        if (link != null && link.startsWith('/')) context.push(link);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintIcon(icon: icon, color: color, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: AppText.tabular(16, FontWeight.w600),
                      ),
                    ),
                    if (n.timeAgo != null) ...[
                      const SizedBox(width: 8),
                      Text(n.timeAgo!, style: AppText.meta),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tabular(
                    14,
                    FontWeight.w400,
                    color: AppColors.textBody,
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          if (n.isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal row of course cards with their thumbnails; the student's
/// enrolled courses first, then the rest of the catalog.
class _HomeCourses extends ConsumerWidget {
  const _HomeCourses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(remoteCatalogProvider(null)).value;
    final mine = ref.watch(remoteMyCoursesProvider).value ?? const <Course>[];
    if (catalog == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    final mineIds = {for (final c in mine) c.id};
    final courses = [...mine, ...catalog.where((c) => !mineIds.contains(c.id))];
    if (courses.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 228,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _HomeCourseCard(
          course: courses[i],
          enrolled: mineIds.contains(courses[i].id),
        ),
      ),
    );
  }
}

class _HomeCourseCard extends StatelessWidget {
  const _HomeCourseCard({required this.course, required this.enrolled});

  final Course course;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      child: AppCard(
        clip: true,
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.md,
        onTap: () => context.push(Routes.courseDetails(course.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CourseThumbnail(
              url: course.thumbnailUrl,
              hue: course.thumbnailHue,
              height: 132,
              shade: false,
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDeep.withValues(alpha: 0.75),
                    borderRadius: AppRadius.badge,
                  ),
                  child: Text(
                    'CLASS ${course.classLevel}',
                    style: AppText.badge(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(14, FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    enrolled
                        ? '✓ Enrolled'
                        : course.priceInr == 0
                        ? 'Free'
                        : formatRupees(course.priceInr),
                    style: AppText.tabular(
                      14,
                      FontWeight.w700,
                      color: enrolled || course.priceInr == 0
                          ? AppColors.success
                          : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
