import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';

/// 11 · PDF viewer — reads attached notes inside the app, page by page.
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({super.key, required this.attachmentId});

  final String attachmentId;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final _controller = PdfViewerController();
  int _page = 1;
  int _pages = 0;

  void _go(int page) {
    if (_pages == 0 || page < 1 || page > _pages) return;
    _controller.goToPage(pageNumber: page);
  }

  @override
  Widget build(BuildContext context) {
    final attachments = ref.watch(lessonAttachmentsProvider);
    final attachment = attachments.firstWhere(
      (a) => a.id == widget.attachmentId,
      orElse: () => attachments.first,
    );
    final size = attachment.sizeLabel
        .replaceAll('PDF • ', '')
        .replaceAll('•', '·');

    return Scaffold(
      backgroundColor: AppColors.fillMutedAlt,
      appBar: AppTopBar(
        title: attachment.title,
        subtitle: _pages == 0 ? size : 'Page $_page of $_pages · $size',
        actions: [
          TextButton.icon(
            onPressed: () => showDemoSnack(context, 'Saved for offline use'),
            icon: const Icon(
              LucideIcons.download,
              size: 15,
              color: AppColors.primary,
            ),
            label: Text(
              'Save',
              style: AppText.tabular(
                13,
                FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: PdfViewer.asset(
        attachment.assetPath,
        controller: _controller,
        params: PdfViewerParams(
          backgroundColor: AppColors.fillMutedAlt,
          margin: 16,
          onViewerReady: (document, controller) =>
              setState(() => _pages = document.pages.length),
          onPageChanged: (page) {
            if (page != null && mounted) setState(() => _page = page);
          },
          loadingBannerBuilder: (context, bytes, total) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          errorBannerBuilder: (context, error, stack, documentRef) =>
              _PdfError(message: '$error'),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _page > 1 ? () => _go(_page - 1) : null,
                child: Text(
                  '‹ Prev',
                  style: AppText.tabular(
                    14,
                    FontWeight.w400,
                    color: _page > 1 ? AppColors.ink : AppColors.textDisabled,
                  ),
                ),
              ),
              Text(
                _pages == 0 ? '–' : '$_page / $_pages',
                style: AppText.tabular(14, FontWeight.w600),
              ),
              TextButton(
                onPressed: _page < _pages ? () => _go(_page + 1) : null,
                child: Text(
                  'Next ›',
                  style: AppText.tabular(
                    14,
                    FontWeight.w400,
                    color: _page < _pages
                        ? AppColors.ink
                        : AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfError extends StatelessWidget {
  const _PdfError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.fileWarning,
              size: 30,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text("Couldn't open this PDF", style: AppText.cardTitleSm),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.meta.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
