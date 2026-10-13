import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/course.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';
import '../../widgets/course_slider.dart';
import '../../widgets/ui_kit.dart';
import 'my_courses_screen.dart';

const _storeTab = 'Explore';
const _mineTab = 'My courses';

/// Courses tab: the student's own courses and the store where crash courses
/// are sold. `?tab=store` opens straight on Explore.
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  late String _tab = _tabFor(widget.initialTab);
  String _query = '';

  static String _tabFor(String? query) =>
      query == 'store' ? _storeTab : _mineTab;

  @override
  void didUpdateWidget(CoursesScreen old) {
    super.didUpdateWidget(old);
    // Navigating to /courses?tab=… while the tab is already open.
    if (widget.initialTab != old.initialTab && widget.initialTab != null) {
      setState(() => _tab = _tabFor(widget.initialTab));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrolled = ref.watch(remoteMyCoursesProvider).value?.length ?? 0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: PageTitle(
                title: _tab == _mineTab ? 'My Courses' : 'Explore',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$enrolled Enrolled',
                    style: AppText.tabular(15, FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: AppText.tabular(16, FontWeight.w400),
                decoration: InputDecoration(
                  hintText: _tab == _mineTab
                      ? 'Search your courses…'
                      : 'Search crash courses…',
                  hintStyle: AppText.tabular(
                    16,
                    FontWeight.w400,
                    color: AppColors.textSubtle,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.fillMuted,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: SegmentedTabs(
                tabs: const [_mineTab, _storeTab],
                selected: _tab,
                onSelected: (tab) => setState(() => _tab = tab),
              ),
            ),
            Expanded(
              child: _tab == _storeTab
                  ? _StoreView(query: _query)
                  : MyCoursesView(
                      query: _query,
                      onExplore: () => setState(() => _tab = _storeTab),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

const _filters = ['All', 'Class 12', 'Class 11', 'Science', 'Commerce', 'Arts'];

bool _matches(Course c, String filter) => switch (filter) {
  'Class 12' => c.classLevel == 12,
  'Class 11' => c.classLevel == 11,
  'Science' => c.subjects.any(
    (s) => const ['Physics', 'Chemistry', 'Biology'].contains(s),
  ),
  'Commerce' => c.subjects.contains('Accountancy'),
  'Arts' => c.subjects.contains('History'),
  _ => true,
};

/// 23 · The store: admin-managed slider, then every paid crash course.
class _StoreView extends ConsumerWidget {
  const _StoreView({this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(exploreFilterProvider);
    final catalog = ref.watch(remoteCatalogProvider(null));
    final mine = ref.watch(remoteMyCoursesProvider).value ?? const <Course>[];
    final enrolledIds = {for (final c in mine) c.id};

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(bannersProvider);
        return ref.refresh(remoteCatalogProvider(null).future);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const CourseSlider(padding: EdgeInsets.fromLTRB(18, 0, 18, 18)),
          ChipRow(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final f in _filters)
                FilterChipPill(
                  label: f,
                  selected: filter == f,
                  onTap: () =>
                      ref.read(exploreFilterProvider.notifier).select(f),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...catalog.when(
            loading: () => const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: EmptyState(
                  icon: LucideIcons.wifiOff,
                  title: 'Could not load courses',
                  body: 'Check your connection and pull down to try again.',
                ),
              ),
            ],
            data: (courses) {
              final q = query.trim().toLowerCase();
              final shown =
                  courses
                      .where((c) => _matches(c, filter))
                      .where(
                        (c) => q.isEmpty || c.title.toLowerCase().contains(q),
                      )
                      .toList()
                    ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
              if (shown.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EmptyState(
                      icon: LucideIcons.bookOpen,
                      title: 'Coming soon',
                      body: filter == 'All'
                          ? 'New crash courses open here as soon as they are published.'
                          : 'No $filter crash courses are open yet.',
                    ),
                  ),
                ];
              }
              return [
                for (final course in shown)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _StoreCard(
                      course: course,
                      enrolled: enrolledIds.contains(course.id),
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.course, required this.enrolled});

  final Course course;
  final bool enrolled;

  @override
  Widget build(BuildContext context) {
    void open() => context.push(Routes.courseDetails(course.id));

    return AppCard(
      clip: true,
      borderRadius: AppRadius.md,
      onTap: open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CourseThumbnail(
            url: course.thumbnailUrl,
            hue: course.thumbnailHue,
            height: course.thumbnailUrl == null ? 112 : 168,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (course.badge != null) ...[
                      _ThumbTag(
                        course.badge!.toUpperCase(),
                        background: AppColors.primaryDeep.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    _ThumbTag(
                      'Class ${course.classLevel}',
                      background: Colors.white.withValues(alpha: 0.22),
                    ),
                    const Spacer(),
                    if (course.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.badge,
                        ),
                        child: Text(
                          '★ ${course.rating}',
                          style: AppText.tabular(12, FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                Text(
                  course.stream ?? course.subjects.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tabular(
                    20,
                    FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppText.tabular(16, FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  [
                    if (course.lessonsCount > 0)
                      '${course.lessonsCount}+ lectures',
                    '${MockData.planDays} days',
                    course.language,
                  ].join(' · '),
                  style: AppText.meta,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: enrolled
                          ? Text(
                              '✓ Enrolled',
                              style: AppText.tabular(
                                14,
                                FontWeight.w600,
                                color: AppColors.success,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRupees(course.priceInr),
                                  style: AppText.tabular(19, FontWeight.w700),
                                ),
                                if (course.discountPercent > 0)
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: formatRupees(
                                            course.originalPriceInr,
                                          ),
                                          style:
                                              AppText.tabular(
                                                12,
                                                FontWeight.w400,
                                                color: AppColors.textMuted,
                                              ).copyWith(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                        ),
                                        TextSpan(
                                          text:
                                              '  ${course.discountPercent}% OFF',
                                          style: AppText.tabular(
                                            12,
                                            FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    PrimaryButton(
                      label: enrolled ? 'Open' : 'Enroll',
                      height: 40,
                      expand: false,
                      onPressed: enrolled
                          ? () => context.push(
                              Routes.curriculum,
                              extra: course.id,
                            )
                          : () => context.push(Routes.checkout(course.id)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbTag extends StatelessWidget {
  const _ThumbTag(this.label, {required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.badge,
      ),
      child: Text(label, style: AppText.badge(color: Colors.white)),
    );
  }
}
