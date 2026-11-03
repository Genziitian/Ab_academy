import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/env.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// 16 · Notes — every chapter PDF from the student's courses, searchable.
/// Shown as the Notes section of the Academics tab.
class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    if (!Env.notesLive) return const _NotesComingSoon();
    final filter = ref.watch(materialsFilterProvider);
    final q = _query.trim().toLowerCase();
    final materials = ref
        .watch(notesLibraryProvider)
        .maybeWhen(data: (all) => all, orElse: () => const <StudyMaterial>[])
        .where((m) => filter == 'All' || m.subject == filter)
        .where(
          (m) =>
              q.isEmpty ||
              m.title.toLowerCase().contains(q) ||
              m.subject.toLowerCase().contains(q),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
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
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
                onTap: () =>
                    ref.read(materialsFilterProvider.notifier).select(label),
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
            children: [for (final m in materials) _NoteRow(material: m)],
          ),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.material});

  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(material.subject);
    return InkWell(
      onTap: () => context.push(Routes.pdf(material.id), extra: material.title),
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
            // Notes open only in the in-app viewer; they are never saved to
            // the phone, so there is no download or offline toggle.
            Text(
              'Open',
              style: AppText.tabular(
                12,
                FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown until the notes library opens (see [Env.notesLive]).
class _NotesComingSoon extends StatelessWidget {
  const _NotesComingSoon();

  static const _subjects = [
    ('Physics', 14, SubjectPalette.physics),
    ('Chemistry', 10, SubjectPalette.chemistry),
    ('Maths', 13, SubjectPalette.mathematics),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        ClipRRect(
          borderRadius: AppRadius.lg,
          child: Image.asset(
            'assets/images/promo/notes.png',
            fit: BoxFit.cover,
            semanticLabel: 'Free notes and solved PYQs',
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            'COMING SOON',
            style: AppText.eyebrow(color: AppColors.primary, size: 11),
          ),
        ),
        const SizedBox(height: 12),
        Text('Chapter notes are on the way.', style: AppText.h2),
        const SizedBox(height: 8),
        Text(
          'A notes PDF and solved PYQs for every Class 12 chapter, in Hindi '
          'and English. They will open right here in the secure viewer.',
          style: AppText.bodyLg,
        ),
        const SizedBox(height: 22),
        for (final (name, chapters, palette) in _subjects) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.tint,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(LucideIcons.fileText, color: palette.ink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.serif(24)),
                      Text('$chapters chapters', style: AppText.meta),
                    ],
                  ),
                ),
                Text(
                  'Coming soon',
                  style: AppText.tabular(
                    12.5,
                    FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
