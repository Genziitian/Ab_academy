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
import '../../utils/format.dart';
import '../../widgets/brand_art.dart';
import '../../widgets/common.dart';
import '../../widgets/course_slider.dart';
import '../../widgets/ui_kit.dart';

/// 06 · Home — greeting, continue learning, feature banners, quick actions,
/// then every course top to bottom.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final unread = ref.watch(unreadCountProvider);
    // Supabase realtime on `notifications` (a timer on sample data).
    ref.watch(realtimeNotificationProvider);
    final firstName = student.fullName.split(' ').first;
    final hasAdminSlides =
        (ref.watch(bannersProvider).value ?? const []).isNotEmpty;

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(Routes.more),
                    child: GradientAvatar(initials: firstName, size: 48),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppText.tabular(
                            13,
                            FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.serif(30, height: 1.1),
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
              const _ContinueCard(),
              // Admin-managed slider (App slider in the console) when it has
              // slides; the app's own feature banners otherwise.
              if (hasAdminSlides)
                const CourseSlider(padding: EdgeInsets.only(bottom: 26))
              else ...[
                const PromoCarousel(),
                const SizedBox(height: 26),
              ],
              const _QuickActions(),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text('Courses for you', style: AppText.serif(28)),
                  ),
                  GestureDetector(
                    onTap: () => context.go(Routes.store),
                    child: Text(
                      'See all',
                      style: AppText.tabular(
                        14,
                        FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _HomeCourses(),
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

/// The student's most recent course, one tap from where they left off.
class _ContinueCard extends ConsumerWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(remoteMyCoursesProvider).value ?? const <Course>[];
    if (mine.isEmpty) return const SizedBox.shrink();
    final course = mine.first;
    final progress = course.progressPercent.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Material(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.courseDetails(course.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTINUE LEARNING',
                  style: AppText.eyebrow(color: AppColors.accent, size: 11.5),
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.serif(28, color: AppColors.surface),
                ),
                if (course.nextUpLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    course.nextUpLabel!,
                    style: AppText.tabular(
                      13.5,
                      FontWeight.w500,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          color: AppColors.accent,
                          backgroundColor: AppColors.primaryDeepRaised,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progress%',
                      style: AppText.tabular(
                        13,
                        FontWeight.w700,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Continue',
                        style: AppText.tabular(
                          14,
                          FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four shortcuts to what students open most.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      (LucideIcons.messageCircle, 'Live doubts', AppColors.accent, Routes.live),
      (LucideIcons.fileText, 'Free notes', AppColors.teal, Routes.notes),
      (LucideIcons.calendarDays, 'Calendar', AppColors.violet, Routes.calendar),
      (LucideIcons.download, 'Downloads', AppColors.primary, Routes.downloads),
    ];
    return Row(
      children: [
        for (final (icon, label, color, route) in items)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    TintIcon(icon: icon, color: color, size: 56),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppText.tabular(12.5, FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
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
          shadowColor: const Color(0x221C1814),
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

/// One announcement / notification: tinted bell, title, body, time.
class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final (icon, color) = switch (n.kind) {
      NotificationKind.live => (LucideIcons.video, const Color(0xFFE8742A)),
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

/// Courses, top to bottom: the student's own first, then the rest of the
/// catalog.
class _HomeCourses extends ConsumerWidget {
  const _HomeCourses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(remoteCatalogProvider(null)).value;
    final mine = ref.watch(remoteMyCoursesProvider).value ?? const <Course>[];
    if (catalog == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    final mineIds = {for (final c in mine) c.id};
    final courses = [...mine, ...catalog.where((c) => !mineIds.contains(c.id))];
    return Column(
      children: [
        for (final c in courses) ...[
          HomeCourseCard(course: c, enrolled: mineIds.contains(c.id)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// Full-width course card: artwork, then class and language, title,
/// teacher and lectures, and the price or enrolment.
class HomeCourseCard extends StatelessWidget {
  const HomeCourseCard({
    super.key,
    required this.course,
    required this.enrolled,
  });

  final Course course;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    final teacher = course.teachers.isEmpty
        ? 'Faculty Team'
        : course.teachers.first.displayName;
    final language =
        course.language.contains('Hindi') && course.language.contains('English')
        ? 'Hindi + English'
        : course.language;
    final free = course.priceInr == 0;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE4DCCF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.courseDetails(course.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CourseThumbnail(
                url: courseArtwork(course),
                hue: course.thumbnailHue,
                shade: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLASS ${course.classLevel}  ·  ${language.toUpperCase()}',
                    style: AppText.tabular(
                      11,
                      FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.serif(24, height: 1.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      teacher,
                      if (course.lessonsCount > 0)
                        '${course.lessonsCount}+ lectures',
                    ].join('  ·  '),
                    style: AppText.tabular(
                      13,
                      FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFECE4D6)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (enrolled)
                        _Badge(
                          label: 'Enrolled',
                          color: AppColors.success,
                          icon: LucideIcons.checkCircle2,
                        )
                      else if (free)
                        _Badge(
                          label: 'Free',
                          color: AppColors.success,
                          icon: LucideIcons.gift,
                        )
                      else ...[
                        Text(
                          formatRupees(course.priceInr),
                          style: AppText.tabular(18, FontWeight.w800),
                        ),
                        if (course.discountPercent > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            formatRupees(course.originalPriceInr),
                            style: AppText.tabular(
                              13,
                              FontWeight.w500,
                              color: AppColors.textSubtle,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.discountPercent}% off',
                            style: AppText.tabular(
                              13,
                              FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                      const Spacer(),
                      Text(
                        enrolled ? 'Continue' : 'View',
                        style: AppText.tabular(
                          14,
                          FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppText.tabular(14, FontWeight.w700, color: color)),
      ],
    );
  }
}
