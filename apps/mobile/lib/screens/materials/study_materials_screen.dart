import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class StudyMaterialsScreen extends ConsumerWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(materialsFilterProvider);
    final materials = ref.watch(filteredMaterialsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Reached from within the Courses section, so that tab stays highlighted.
      bottomNavigationBar: AppBottomNav(
        active: AppTab.courses,
        onSelected: (tab) => context.go(_tabRoute(tab)),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SquareIconButton(
                          icon: LucideIcons.chevronLeft,
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 12),
                        Text('Study Materials', style: AppText.h3.copyWith(fontSize: 22)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ChipRow(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final label in ['All', ...MockData.allSubjects.take(4)])
                        FilterChipPill(
                          label: label,
                          selected: filter == label,
                          onTap: () => ref.read(materialsFilterProvider.notifier).select(label),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: materials.isEmpty
                  ? Center(
                      child: Text(
                        'No materials for this subject yet.',
                        style: AppText.metaSm.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: materials.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _MaterialCard(material: materials[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _tabRoute(AppTab tab) => switch (tab) {
    AppTab.home => Routes.home,
    AppTab.courses => Routes.courses,
    AppTab.live => Routes.live,
    AppTab.community => Routes.community,
    AppTab.profile => Routes.profile,
  };
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material});

  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(material.subject);
    final isHindi = material.subject == 'Hindi';
    final badgeTint = switch (material.kind) {
      MaterialKind.pdf => isHindi ? AppColors.hindiTint : AppColors.pdfTint,
      MaterialKind.doc => AppColors.englishTint,
    };
    final badgeInk = switch (material.kind) {
      MaterialKind.pdf => isHindi ? AppColors.hindi : const Color(0xFFC43B3B),
      MaterialKind.doc => AppColors.english,
    };

    final leading = IconTile(
      background: badgeTint,
      label: isHindi ? 'हि' : material.badge,
      labelStyle: isHindi
          ? AppText.devanagari(13, FontWeight.w700, color: badgeInk)
          : AppText.badge(color: badgeInk, size: 10).copyWith(letterSpacing: 0),
      size: 44,
      radius: 13,
    );

    // Simple rows just get a download affordance; the richer cards show actions.
    if (!material.showActions && !material.isOffline) {
      return AppCard(
        onTap: () => showDemoSnack(context, 'Downloading ${material.title}'),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.title, style: AppText.cardTitle),
                  const SizedBox(height: 4),
                  Text(material.sizeLabel, style: AppText.metaSm),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.download, size: 18, color: AppColors.primary),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.subject.toUpperCase(),
                      style: AppText.eyebrow(color: palette.ink, letterSpacing: 0.7),
                    ),
                    const SizedBox(height: 4),
                    Text(material.title, style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Text(material.metaLine, style: AppText.metaSm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (material.isOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: const BoxDecoration(color: Color(0xFFEDF6F1), borderRadius: AppRadius.xs),
              child: Row(
                children: [
                  const Icon(LucideIcons.check, size: 15, color: AppColors.scienceInk),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Available offline',
                      style: AppText.tabular(12.5, FontWeight.w600, color: AppColors.scienceInk),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showDemoSnack(context, 'Removed from offline downloads'),
                    child: Text(
                      'Remove',
                      style: AppText.tabular(12, FontWeight.w600, color: AppColors.textSubtle),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'View',
                    height: 42,
                    onPressed: () => showDemoSnack(context, 'Opening ${material.title}'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SecondaryButton(
                    label: 'Download',
                    height: 42,
                    icon: LucideIcons.download,
                    onPressed: () => showDemoSnack(context, 'Saved for offline use'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
