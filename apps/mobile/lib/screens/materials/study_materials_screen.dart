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
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// 16 · Notes — every chapter PDF from the student's courses, searchable.
/// This is the fourth bottom-nav tab (it replaced Community).
class StudyMaterialsScreen extends ConsumerStatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  ConsumerState<StudyMaterialsScreen> createState() =>
      _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends ConsumerState<StudyMaterialsScreen> {
  String _query = '';
  late final Set<String> _offline = {
    for (final m in MockData.materials)
      if (m.isOffline) m.id,
  };

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(materialsFilterProvider);
    final q = _query.trim().toLowerCase();
    final materials = ref
        .watch(filteredMaterialsProvider)
        .where(
          (m) =>
              q.isEmpty ||
              m.title.toLowerCase().contains(q) ||
              m.subject.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Text('Notes', style: AppText.h2),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                cursorColor: AppColors.primary,
                style: AppText.tabular(14, FontWeight.w400),
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  hintStyle: AppText.tabular(
                    14,
                    FontWeight.w400,
                    color: AppColors.textSubtle,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 17,
                    color: AppColors.textSubtle,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.sm,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.sm,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ChipRow(
              children: [
                for (final label in ['All', ...MockData.scienceSubjects])
                  FilterChipPill(
                    label: label == 'Mathematics' ? 'Maths' : label,
                    selected: filter == label,
                    onTap: () => ref
                        .read(materialsFilterProvider.notifier)
                        .select(label),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (materials.isEmpty)
              EmptyState(
                icon: LucideIcons.fileSearch,
                title: 'No notes found',
                body: q.isEmpty
                    ? 'Teachers have not uploaded $filter notes yet.'
                    : 'Nothing matches “$_query”.',
              )
            else
              ListCard(
                children: [
                  for (final m in materials)
                    _NoteRow(
                      material: m,
                      offline: _offline.contains(m.id),
                      onToggleOffline: () => setState(() {
                        if (!_offline.remove(m.id)) {
                          _offline.add(m.id);
                        }
                      }),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.material,
    required this.offline,
    required this.onToggleOffline,
  });

  final StudyMaterial material;
  final bool offline;
  final VoidCallback onToggleOffline;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(material.subject);
    return InkWell(
      // Every note opens the bundled sample until notes come from storage.
      onTap: () =>
          context.push(Routes.pdf(MockData.lessonAttachments.first.id)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const PdfBadge(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.subject.toUpperCase(),
                    style: AppText.tabular(
                      11,
                      FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(material.title, style: AppText.rowTitle),
                  const SizedBox(height: 1),
                  Text(
                    material.metaLine.replaceAll('•', '·'),
                    style: AppText.meta,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggleOffline,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  offline ? '✓ Offline' : 'Open',
                  style: AppText.tabular(
                    12,
                    FontWeight.w600,
                    color: offline ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
