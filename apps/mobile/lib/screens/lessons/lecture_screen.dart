import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/lesson_extras.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../data/providers/remote_providers.dart';
import '../../data/remote/repositories.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';
import '../../widgets/secure_youtube_player.dart';

/// 09 / 10 · Lecture — player, then About / Discussion / Notes.
/// Discussion is the doubt thread: questions land in the teacher's queue.
class LectureScreen extends ConsumerStatefulWidget {
  const LectureScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends ConsumerState<LectureScreen> {
  static const _tabs = ['About', 'Discussion', 'Notes'];

  String _tab = 'About';
  bool _fullscreen = false;

  /// True after the full-screen button was used: the orientation is then
  /// pinned to what the button chose, and turning the device is ignored until
  /// the student leaves the lecture. Otherwise the player follows the device
  /// like YouTube: landscape is full screen, portrait is not.
  bool _pinned = false;

  static const _portrait = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];
  static const _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  @override
  void initState() {
    super.initState();
    // The rest of the app is portrait-only (main.dart); the lecture may turn.
    SystemChrome.setPreferredOrientations([..._portrait, ..._landscape]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(_portrait);
    super.dispose();
  }

  /// The full-screen button: landscape + immersive, or back to portrait.
  Future<void> _toggleFullscreen() async {
    _pinned = true;
    await _setFullscreen(!_fullscreen);
  }

  Future<void> _setFullscreen(bool value) async {
    if (mounted) setState(() => _fullscreen = value);
    await SystemChrome.setEnabledSystemUIMode(
      value ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    if (_pinned) {
      await SystemChrome.setPreferredOrientations(
        value ? _landscape : _portrait,
      );
    }
  }

  /// Device turned while orientation is free: follow it.
  void _followOrientation(Orientation orientation) {
    if (_pinned) return;
    final landscape = orientation == Orientation.landscape;
    if (landscape != _fullscreen) _setFullscreen(landscape);
  }

  void _back() {
    if (_fullscreen) {
      _toggleFullscreen();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    if ((orientation == Orientation.landscape) != _fullscreen && !_pinned) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _followOrientation(orientation),
      );
    }
    final topInset = _fullscreen ? 0.0 : MediaQuery.paddingOf(context).top;
    // The player stays the first child in both layouts, so going full screen
    // resizes it instead of reloading the video.
    final playerHeight = _fullscreen
        ? size.height
        : topInset + size.width * 9 / 16;

    return PopScope(
      canPop: !_fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _fullscreen) _toggleFullscreen();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _fullscreen ? Colors.black : AppColors.surface,
          body: Column(
            children: [
              Container(
                height: playerHeight,
                color: Colors.black,
                padding: EdgeInsets.only(top: topInset),
                child: _LecturePlayerArea(
                  lessonId: widget.lessonId,
                  fullscreen: _fullscreen,
                  onToggleFullscreen: _toggleFullscreen,
                  onBack: _back,
                ),
              ),
              if (!_fullscreen) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: UnderlineTabs(
                      tabs: _tabs,
                      selected: _tab,
                      gap: 20,
                      onSelected: (value) => setState(() => _tab = value),
                    ),
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    'Discussion' => _DiscussionTab(lessonId: widget.lessonId),
                    'Notes' => _NotesTab(lessonId: widget.lessonId),
                    _ => _AboutTab(lessonId: widget.lessonId),
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fetches the lecture's YouTube id at play time and hands it to the secure
/// player. The id lives only in this widget's memory.
class _LecturePlayerArea extends ConsumerWidget {
  const _LecturePlayerArea({
    required this.lessonId,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onBack,
  });

  final String lessonId;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(lessonYoutubeIdProvider(lessonId));
    final student = ref.watch(studentProvider);

    return video.when(
      loading: () => _PlayerMessage(
        onBack: onBack,
        child: const SizedBox.square(
          dimension: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
      error: (error, _) => _PlayerMessage(
        onBack: onBack,
        child: _MessageText(
          error is PlaybackDenied
              ? 'Enroll in this course to watch the lecture.'
              : 'Could not load the lecture. Check your connection and try again.',
          action: error is PlaybackDenied
              ? null
              : () => ref.invalidate(lessonYoutubeIdProvider(lessonId)),
        ),
      ),
      data: (id) => id == null
          ? _PlayerMessage(
              onBack: onBack,
              child: const _MessageText('This lecture has no video yet.'),
            )
          : SecureYouTubePlayer(
              videoId: id,
              watermark: student.phone,
              fullscreen: fullscreen,
              onToggleFullscreen: onToggleFullscreen,
              onBack: onBack,
            ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  const _PlayerMessage({required this.child, required this.onBack});

  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: child),
        Positioned(
          left: 4,
          top: 4,
          child: IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText(this.text, {this.action});

  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppText.tabular(13, FontWeight.w500, color: Colors.white),
          ),
          if (action != null)
            TextButton(
              onPressed: action,
              child: Text(
                'Retry',
                style: AppText.tabular(
                  13,
                  FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AboutTab extends ConsumerWidget {
  const _AboutTab({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(lessonInfoProvider(lessonId));
    if (async.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    final info = async.value;
    // Sample data (no backend): keep the design preview.
    final title = info?.title ?? MockData.lectureTitle;
    final eyebrow = info == null
        ? MockData.lectureEyebrow
        : [
            if (info.subject.isNotEmpty) info.subject,
            if (info.chapter.isNotEmpty) info.chapter,
          ].join('  ·  ').toUpperCase();
    final teacher = info?.teacher ?? 'Amit Sir';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          eyebrow,
          style: AppText.tabular(
            11,
            FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppText.tabular(
            20,
            FontWeight.w700,
            letterSpacing: -0.4,
          ).copyWith(height: 1.3),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            InitialsAvatar(
              initials: teacher.trim().isEmpty ? 'T' : teacher.trim()[0],
              size: 30,
              fontSize: 12,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                [
                  teacher,
                  if ((info?.durationMinutes ?? 0) > 0)
                    '${info!.durationMinutes} min',
                ].join('  ·  '),
                style: AppText.tabular(
                  14,
                  FontWeight.w500,
                  color: AppColors.textBody,
                ),
              ),
            ),
          ],
        ),
        if (info != null && info.courseTitle.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7EBF3)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.bookOpen,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info.courseTitle,
                    style: AppText.tabular(14, FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (info != null && info.chapterLessons.length > 1) ...[
          const SizedBox(height: 26),
          Text(
            'In this chapter',
            style: AppText.tabular(16, FontWeight.w700, letterSpacing: -0.2),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EBF3)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, l) in info.chapterLessons.indexed) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 62,
                      color: Color(0xFFF1F3F8),
                    ),
                  _ChapterLessonRow(lesson: l, playing: l.id == lessonId),
                ],
              ],
            ),
          ),
        ],
        if (info == null) ...[
          const SizedBox(height: 20),
          Text('About this lesson', style: AppText.cardTitle),
          const SizedBox(height: 6),
          Text(MockData.lectureAbout, style: AppText.body),
        ],
      ],
    );
  }
}

class _ChapterLessonRow extends StatelessWidget {
  const _ChapterLessonRow({required this.lesson, required this.playing});

  final ({String id, String title, bool isNotes, int minutes}) lesson;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final color = lesson.isNotes ? const Color(0xFFD9480F) : AppColors.primary;
    return InkWell(
      onTap: playing
          ? null
          : () => lesson.isNotes
                ? context.push(
                    Routes.pdf(lesson.id, lesson: true),
                    extra: lesson.title,
                  )
                : context.pushReplacement(Routes.lesson(lesson.id)),
      child: Container(
        color: playing ? AppColors.primary.withValues(alpha: 0.05) : null,
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                lesson.isNotes ? LucideIcons.fileText : LucideIcons.play,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(14, FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playing
                        ? 'Now playing'
                        : lesson.isNotes
                        ? 'Notes  ·  PDF'
                        : 'Lecture${lesson.minutes > 0 ? '  ·  ${lesson.minutes} min' : ''}',
                    style: AppText.tabular(
                      12,
                      playing ? FontWeight.w700 : FontWeight.w500,
                      color: playing ? AppColors.primary : AppColors.textMuted,
                    ),
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

class _DiscussionTab extends ConsumerWidget {
  const _DiscussionTab({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(lessonCommentsProvider(lessonId));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            children: [
              Text(
                "Questions about this lesson go to your teacher's doubt queue.",
                style: AppText.meta,
              ),
              const SizedBox(height: 16),
              for (final comment in comments) ...[
                _CommentTile(comment: comment),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        MessageComposer(
          hint: 'Ask a question about this lesson…',
          onSend: (body) {
            ref.read(lessonCommentsProvider(lessonId).notifier).post(body);
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final LessonComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(initials: comment.initials, size: 30, fontSize: 11),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: comment.isMe ? 'You' : comment.author,
                      style: AppText.tabular(13, FontWeight.w600),
                    ),
                    TextSpan(
                      text: ' · ${comment.timeLabel}',
                      style: AppText.tabular(
                        13,
                        FontWeight.w400,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                comment.body,
                style: AppText.tabular(
                  13,
                  FontWeight.w400,
                  color: AppColors.textBody,
                ).copyWith(height: 1.55),
              ),
              for (final reply in comment.replies) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadius.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InitialsAvatar(
                        initials: reply.initials,
                        size: 24,
                        fontSize: 9,
                        background: AppColors.primary,
                        foreground: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply.author,
                                  style: AppText.tabular(12, FontWeight.w600),
                                ),
                                if (reply.isTeacher) ...[
                                  const SizedBox(width: 6),
                                  const StatusBadge.teacher(),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              reply.body,
                              style: AppText.tabular(
                                13,
                                FontWeight.w400,
                                color: AppColors.textBody,
                              ).copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(remoteLessonNotesProvider(lessonId));
    final attachments = notes.value ?? const <LessonNote>[];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Attached notes', style: AppText.cardTitle),
        const SizedBox(height: 4),
        Text('Open them here — no download needed.', style: AppText.meta),
        const SizedBox(height: 14),
        if (notes.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (attachments.isEmpty)
          const EmptyState(
            icon: LucideIcons.fileText,
            title: 'No notes yet',
            body: 'Your teacher has not attached notes to this lecture.',
          ),
        for (final attachment in attachments) ...[
          AppCard(
            padding: const EdgeInsets.all(12),
            borderRadius: AppRadius.sm,
            onTap: () => context.push(
              Routes.pdf(attachment.id),
              extra: attachment.title,
            ),
            child: Row(
              children: [
                const PdfBadge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attachment.title, style: AppText.rowTitle),
                      Text(attachment.meta, style: AppText.meta),
                    ],
                  ),
                ),
                Text(
                  'Open',
                  style: AppText.tabular(
                    13,
                    FontWeight.w600,
                    color: AppColors.primary,
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
