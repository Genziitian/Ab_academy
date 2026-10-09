import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/content.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final videos = downloads.where((d) => d.kind == DownloadKind.video).toList();
    final notes = downloads.where((d) => d.kind == DownloadKind.pdf).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Downloads', style: AppText.h3),
                  const SizedBox(height: 16),
                  const _StorageMeter(),
                ],
              ),
            ),
            Expanded(
              child: downloads.isEmpty
                  ? const _EmptyDownloads()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      children: [
                        if (videos.isNotEmpty) ...[
                          const GroupLabel('VIDEOS'),
                          const SizedBox(height: 10),
                          for (final item in videos) ...[
                            _DownloadCard(item: item),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 10),
                        ],
                        if (notes.isNotEmpty) ...[
                          const GroupLabel('NOTES & PDFS'),
                          const SizedBox(height: 10),
                          for (final item in notes) ...[
                            _DownloadCard(item: item),
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
}

class _StorageMeter extends StatelessWidget {
  const _StorageMeter();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(MockData.downloadsUsedLabel, style: AppText.cardTitleSm),
            Text(MockData.downloadsFreeLabel, style: AppText.meta),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 7,
          child: ClipRRect(
            borderRadius: AppRadius.pill,
            child: Row(
              children: [
                Expanded(
                  flex: (MockData.downloadsVideoShare * 100).round(),
                  child: Container(color: AppColors.primary),
                ),
                Expanded(
                  flex: (MockData.downloadsNotesShare * 100).round(),
                  child: Container(color: const Color(0xFF8C91D6)),
                ),
                Expanded(
                  flex: ((1 - MockData.downloadsVideoShare - MockData.downloadsNotesShare) * 100)
                      .round(),
                  child: Container(color: AppColors.trackMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            const _LegendDot(color: AppColors.primary, label: 'Videos 1.5 GB'),
            const SizedBox(width: 16),
            const _LegendDot(color: Color(0xFF8C91D6), label: 'Notes 0.3 GB'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.tabular(11.5, FontWeight.w500, color: AppColors.textMuted)),
      ],
    );
  }
}

class _DownloadCard extends ConsumerWidget {
  const _DownloadCard({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SubjectPalette.fromName(item.subject);
    final isVideo = item.kind == DownloadKind.video;
    final downloading = item.state == DownloadState.downloading;
    final isHindi = item.subject == 'Hindi';

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (isVideo)
            Container(
              width: 64,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.tint,
                borderRadius: const BorderRadius.all(Radius.circular(11)),
              ),
              child: Icon(Icons.play_arrow_rounded, size: 20, color: palette.ink),
            )
          else
            IconTile(
              background: isHindi ? AppColors.hindiTint : AppColors.pdfTint,
              label: isHindi ? 'हि' : 'PDF',
              labelStyle: isHindi
                  ? AppText.devanagari(13, FontWeight.w700, color: AppColors.hindi)
                  : AppText.badge(
                      color: const Color(0xFFC43B3B),
                      size: 9.5,
                    ).copyWith(letterSpacing: 0),
              size: 44,
              radius: 12,
            ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppText.cardTitleSm),
                const SizedBox(height: 5),
                Text(item.metaLabel, style: AppText.metaSm),
                if (downloading) ...[
                  const SizedBox(height: 6),
                  ProgressBar(value: item.progress, height: 5),
                ] else if (isVideo) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.check, size: 13, color: AppColors.scienceInk),
                      const SizedBox(width: 6),
                      Text(
                        'Available offline',
                        style: AppText.tabular(11.5, FontWeight.w600, color: AppColors.scienceInk),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!downloading) ...[
            const SizedBox(width: 8),
            if (isVideo)
              GestureDetector(
                onTap: () => _confirmRemove(context, ref),
                behavior: HitTestBehavior.opaque,
                child: const Icon(LucideIcons.trash2, size: 18, color: AppColors.textFaint),
              )
            else
              GestureDetector(
                onTap: () => _confirmRemove(context, ref),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Remove',
                  style: AppText.tabular(12, FontWeight.w600, color: AppColors.textSubtle),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remove download?', style: AppText.cardTitle),
              const SizedBox(height: 12),
              Text(
                'This lesson will no longer be available offline.',
                style: AppText.tabular(
                  12.5,
                  FontWeight.w400,
                  color: AppColors.textMuted,
                ).copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.xs,
                          border: Border.all(color: AppColors.borderStrong, width: 1.5),
                        ),
                        child: Text('Cancel', style: AppText.tabular(13, FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC43B3B),
                          borderRadius: AppRadius.xs,
                        ),
                        child: Text(
                          'Remove',
                          style: AppText.tabular(13, FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed ?? false) {
      ref.read(downloadsProvider.notifier).remove(item.id);
    }
  }
}

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.download, size: 30, color: AppColors.textDisabled),
            const SizedBox(height: 10),
            Text('No downloads yet', style: AppText.tabular(13.5, FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Save lessons to watch without internet.',
              textAlign: TextAlign.center,
              style: AppText.meta.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
