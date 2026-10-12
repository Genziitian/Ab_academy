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
import '../../widgets/common.dart';

/// 17 · Downloads — storage meter and everything saved for offline.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Downloads'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const _StorageMeter(),
          const SizedBox(height: 14),
          if (downloads.isEmpty)
            const EmptyState(
              icon: LucideIcons.downloadCloud,
              title: 'Nothing downloaded',
              body:
                  'Download lectures and notes on wifi to study without data.',
            )
          else
            ListCard(
              children: [
                for (final item in downloads) _DownloadRow(item: item),
              ],
            ),
          const SizedBox(height: 14),
          Text(
            'Downloads play offline inside the app for as long as your course is active.',
            style: AppText.meta.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StorageMeter extends StatelessWidget {
  const _StorageMeter();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MockData.downloadsUsedLabel,
                style: AppText.tabular(13, FontWeight.w600),
              ),
              Text(MockData.downloadsFreeLabel, style: AppText.label),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (MockData.downloadsVideoShare * 100).round(),
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: (MockData.downloadsNotesShare * 100).round(),
                    child: Container(color: AppColors.violet),
                  ),
                  Expanded(
                    flex:
                        100 -
                        ((MockData.downloadsVideoShare +
                                    MockData.downloadsNotesShare) *
                                100)
                            .round(),
                    child: Container(color: AppColors.trackMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _Legend(color: AppColors.primary, label: 'Videos'),
              SizedBox(width: 16),
              _Legend(color: AppColors.violet, label: 'Notes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.tabular(
            12,
            FontWeight.w400,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

class _DownloadRow extends ConsumerStatefulWidget {
  const _DownloadRow({required this.item});

  final DownloadItem item;

  @override
  ConsumerState<_DownloadRow> createState() => _DownloadRowState();
}

class _DownloadRowState extends ConsumerState<_DownloadRow> {
  bool _paused = false;

  void _open() {
    if (widget.item.kind == DownloadKind.video) {
      context.push(Routes.lesson('ch1-l3'));
    } else {
      context.push(Routes.pdf(MockData.lessonAttachments.first.id));
    }
  }

  Future<void> _menu() async {
    final video = widget.item.kind == DownloadKind.video;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                video ? LucideIcons.play : LucideIcons.fileText,
                size: 20,
              ),
              title: Text(video ? 'Play' : 'Open', style: AppText.rowTitle),
              onTap: () => Navigator.of(context).pop('open'),
            ),
            ListTile(
              leading: const Icon(
                LucideIcons.trash2,
                size: 20,
                color: AppColors.liveInk,
              ),
              title: Text(
                'Remove download',
                style: AppText.rowTitle.copyWith(color: AppColors.liveInk),
              ),
              onTap: () => Navigator.of(context).pop('remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'open') _open();
    if (action == 'remove') {
      ref.read(downloadsProvider.notifier).remove(widget.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final video = item.kind == DownloadKind.video;
    final downloading = item.state == DownloadState.downloading;
    final palette = SubjectPalette.fromName(item.subject);
    final meta = downloading && _paused
        ? 'Paused · ${(item.progress * 100).round()}%'
        : item.metaLabel.replaceAll('•', '·');

    return InkWell(
      onTap: downloading ? null : _open,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: video ? palette.tint : AppColors.pdfTint,
                borderRadius: AppRadius.xs,
              ),
              child: video
                  ? Icon(Icons.play_arrow_rounded, size: 18, color: palette.ink)
                  : Text(
                      'PDF',
                      style: AppText.tabular(
                        9,
                        FontWeight.w700,
                        color: AppColors.liveInk,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppText.rowTitle),
                  const SizedBox(height: 1),
                  Text(
                    meta,
                    style: AppText.tabular(
                      12,
                      FontWeight.w400,
                      color: downloading && !_paused
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  if (downloading) ...[
                    const SizedBox(height: 6),
                    ProgressBar(value: item.progress, height: 4),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (downloading)
              TextButton(
                onPressed: () => setState(() => _paused = !_paused),
                child: Text(
                  _paused ? 'Resume' : 'Pause',
                  style: AppText.tabular(
                    12,
                    FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'More',
                onPressed: _menu,
                icon: const Icon(
                  LucideIcons.moreHorizontal,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
