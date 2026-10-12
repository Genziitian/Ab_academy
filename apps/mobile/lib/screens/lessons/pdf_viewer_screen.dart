import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/providers/app_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../data/remote/repositories.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/secure_screen.dart';
import '../../widgets/common.dart';

/// 11 · In-app PDF viewer for class notes.
///
/// The PDF arrives as bytes from the `notes` Edge Function (which reads it
/// from Google Drive or the private bucket) and is rendered from memory —
/// no link, no file on disk, no share or download. On Android screenshots and
/// screen recording are blocked while it is open, and every page carries a
/// faint watermark with the student's number.
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.id,
    this.title,
    this.byLesson = false,
  });

  /// A note (lesson_resources) id, or a lesson id when [byLesson] is true —
  /// then the lesson's first note opens.
  final String id;
  final String? title;
  final bool byLesson;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final _controller = PdfViewerController();
  int _page = 1;
  int _pages = 0;

  @override
  void initState() {
    super.initState();
    SecureScreen.enable();
  }

  @override
  void dispose() {
    SecureScreen.disable();
    super.dispose();
  }

  void _go(int page) {
    if (_pages == 0 || page < 1 || page > _pages) return;
    _controller.goToPage(pageNumber: page);
  }

  @override
  Widget build(BuildContext context) {
    // A curriculum "notes" row knows only its lesson; resolve its first note.
    final LessonNote? resolved;
    String? noteId;
    if (widget.byLesson) {
      final notes = ref.watch(remoteLessonNotesProvider(widget.id));
      resolved = notes.value?.firstOrNull;
      noteId = resolved?.id;
      if (notes.hasValue && resolved == null) {
        return _Shell(
          title: widget.title ?? 'Class notes',
          child: const _Message(
            icon: LucideIcons.fileX,
            text: 'No notes have been added to this lesson yet.',
          ),
        );
      }
    } else {
      resolved = null;
      noteId = widget.id;
    }

    final title = widget.title ?? resolved?.title ?? 'Class notes';
    if (noteId == null) {
      return _Shell(
        title: title,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final bytes = ref.watch(noteBytesProvider(noteId));
    final watermark = ref.watch(studentProvider).phone;

    return _Shell(
      title: title,
      subtitle: _pages == 0 ? null : 'Page $_page of $_pages',
      bottom: _pages == 0 ? null : _pager(),
      child: bytes.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        error: (error, _) => _Message(
          icon: error is NoteUnavailable && error.denied
              ? LucideIcons.lock
              : LucideIcons.fileWarning,
          text: error is NoteUnavailable
              ? error.message
              : 'These notes could not be opened.',
          onRetry: error is NoteUnavailable && error.denied
              ? null
              : () => ref.invalidate(noteBytesProvider(noteId!)),
        ),
        data: (data) => Stack(
          children: [
            PdfViewer.data(
              data,
              // Identifies the document to the cache; deliberately not a URL.
              sourceName: 'note-$noteId',
              controller: _controller,
              params: PdfViewerParams(
                backgroundColor: AppColors.fillMutedAlt,
                margin: 16,
                // Selecting text would let it be copied out.
                textSelectionParams: const PdfTextSelectionParams(
                  enabled: false,
                ),
                onViewerReady: (document, controller) =>
                    setState(() => _pages = document.pages.length),
                onPageChanged: (page) {
                  if (page != null && mounted) setState(() => _page = page);
                },
                loadingBannerBuilder: (context, bytes, total) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                errorBannerBuilder: (context, error, stack, documentRef) =>
                    const _Message(
                      icon: LucideIcons.fileWarning,
                      text: 'This file is not a readable PDF.',
                    ),
              ),
            ),
            if (watermark.isNotEmpty)
              Positioned.fill(child: _Watermark(text: watermark)),
          ],
        ),
      ),
    );
  }

  Widget _pager() {
    return Container(
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
              '$_page / $_pages',
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
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.title,
    required this.child,
    this.subtitle,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fillMutedAlt,
      appBar: AppTopBar(title: title, subtitle: subtitle),
      body: child,
      bottomNavigationBar: bottom,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: AppColors.textSubtle),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: AppText.cardTitleSm),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Faint diagonal text tiled over the pages, so a photo of the screen still
/// shows whose account the notes came from.
class _Watermark extends StatelessWidget {
  const _Watermark({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gapX = 190.0;
            const gapY = 140.0;
            final cols = (constraints.maxWidth / gapX).ceil() + 1;
            final rows = (constraints.maxHeight / gapY).ceil() + 1;
            return Stack(
              children: [
                for (var r = 0; r < rows; r++)
                  for (var c = 0; c < cols; c++)
                    Positioned(
                      left: c * gapX + (r.isOdd ? gapX / 2 : 0) - 40,
                      top: r * gapY,
                      child: Transform.rotate(
                        angle: -pi / 8,
                        child: Text(
                          text,
                          style: AppText.tabular(
                            12,
                            FontWeight.w600,
                            color: AppColors.ink.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
