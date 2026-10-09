import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// Reads an attached PDF inside the app — no external viewer, no download step.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key, required this.attachmentId});

  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments = ref.watch(lessonAttachmentsProvider);
    final attachment = attachments.firstWhere(
      (a) => a.id == attachmentId,
      orElse: () => attachments.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: attachment.title,
              subtitle: attachment.sizeLabel,
              actions: [
                SquareIconButton(
                  icon: LucideIcons.download,
                  onPressed: () => showDemoSnack(context, 'Saved for offline use'),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFE9EAEF),
                child: PdfViewer.asset(
                  attachment.assetPath,
                  params: PdfViewerParams(
                    backgroundColor: const Color(0xFFE9EAEF),
                    loadingBannerBuilder: (context, bytes, total) => const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primaryTint,
                        ),
                      ),
                    ),
                    errorBannerBuilder: (context, error, stack, documentRef) =>
                        _PdfError(message: '$error'),
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
            const Icon(LucideIcons.fileWarning, size: 30, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text("Couldn't open this PDF", style: AppText.tabular(13.5, FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: AppText.meta.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
