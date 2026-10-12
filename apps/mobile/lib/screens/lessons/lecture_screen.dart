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
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';
import '../../widgets/secure_youtube_player.dart';

/// 09 / 10 · Lecture — player, then About / Discussion / Notes / Feedback.
/// Discussion is the doubt thread: questions land in the teacher's queue.
class LectureScreen extends ConsumerStatefulWidget {
  const LectureScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends ConsumerState<LectureScreen> {
  static const _tabs = ['About', 'Discussion', 'Notes', 'Feedback'];

  String _tab = 'About';
  bool _fullscreen = false;

  @override
  void dispose() {
    if (_fullscreen) _restoreOrientation();
    super.dispose();
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    setState(() => _fullscreen = next);
    if (next) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await _restoreOrientation();
    }
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
                    'Notes' => const _NotesTab(),
                    'Feedback' => _FeedbackTab(lessonId: widget.lessonId),
                    _ => const _AboutTab(),
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

class _AboutTab extends StatefulWidget {
  const _AboutTab();

  @override
  State<_AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<_AboutTab> {
  bool _saved = false;
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          MockData.lectureEyebrow,
          style: AppText.eyebrow(color: AppColors.primary, size: 12),
        ),
        const SizedBox(height: 8),
        Text(MockData.lectureTitle, style: AppText.h5),
        const SizedBox(height: 8),
        Row(
          children: [
            const InitialsAvatar(initials: 'AS', size: 26, fontSize: 10),
            const SizedBox(width: 8),
            Text('Amit Sir', style: AppText.tabular(14, FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _LectureAction(
              icon: LucideIcons.download,
              label: 'Download',
              onTap: () =>
                  showDemoSnack(context, 'Downloading for offline use'),
            ),
            const SizedBox(width: 8),
            _LectureAction(
              icon: _saved ? Icons.star_rounded : Icons.star_outline_rounded,
              label: _saved ? 'Saved' : 'Save',
              onTap: () => setState(() => _saved = !_saved),
            ),
            const SizedBox(width: 8),
            _LectureAction(
              icon: LucideIcons.check,
              label: _complete ? 'Completed' : 'Complete',
              iconColor: AppColors.success,
              highlighted: _complete,
              onTap: () => setState(() => _complete = !_complete),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('About this lesson', style: AppText.cardTitle),
        const SizedBox(height: 6),
        Text(MockData.lectureAbout, style: AppText.body),
        const SizedBox(height: 20),
        Text('Next lesson', style: AppText.cardTitle),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(12),
          borderRadius: AppRadius.sm,
          onTap: () => context.push(Routes.liveLobby),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.liveTint,
                  borderRadius: AppRadius.xs,
                ),
                child: const LiveDot(color: AppColors.liveInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class 04 · Practice Session',
                      style: AppText.tabular(13, FontWeight.w600),
                    ),
                    Text(
                      'Live today · 6:00 PM',
                      style: AppText.tabular(
                        11,
                        FontWeight.w400,
                        color: AppColors.liveInk,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LectureAction extends StatelessWidget {
  const _LectureAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: highlighted ? AppColors.successTint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sm,
          side: BorderSide(
            color: highlighted ? AppColors.successTint : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: SizedBox(
            height: 62,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: iconColor),
                const SizedBox(height: 4),
                Text(label, style: AppText.tabular(11, FontWeight.w600)),
              ],
            ),
          ),
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
  const _NotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments = ref.watch(lessonAttachmentsProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Attached notes', style: AppText.cardTitle),
        const SizedBox(height: 4),
        Text('Open them here — no download needed.', style: AppText.meta),
        const SizedBox(height: 14),
        for (final attachment in attachments) ...[
          AppCard(
            padding: const EdgeInsets.all(12),
            borderRadius: AppRadius.sm,
            onTap: () => context.push(Routes.pdf(attachment.id)),
            child: Row(
              children: [
                const PdfBadge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attachment.title, style: AppText.rowTitle),
                      Text(
                        attachment.sizeLabel.replaceAll('•', '·'),
                        style: AppText.meta,
                      ),
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

class _FeedbackTab extends ConsumerStatefulWidget {
  const _FeedbackTab({required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<_FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends ConsumerState<_FeedbackTab> {
  final _controller = TextEditingController();
  int _pending = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = ref.watch(lessonFeedbackProvider(widget.lessonId));
    final selected = _pending > 0 ? _pending : (feedback.myRating ?? 0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text(
              feedback.averageRating.toStringAsFixed(1),
              style: AppText.tabular(36, FontWeight.w700, letterSpacing: -0.6),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '★★★★★',
                  style: AppText.tabular(
                    18,
                    FontWeight.w400,
                    color: const Color(0xFFE0A33A),
                    letterSpacing: 2,
                  ),
                ),
                Text('${feedback.ratingCount} ratings', style: AppText.meta),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          feedback.hasRated ? 'Your rating' : 'Rate this lesson',
          style: AppText.cardTitle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var star = 1; star <= 5; star++)
              Semantics(
                button: true,
                label: '$star star${star > 1 ? 's' : ''}',
                child: GestureDetector(
                  onTap: () => setState(() => _pending = star),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 34,
                      color: star <= selected
                          ? const Color(0xFFE0A33A)
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _controller,
          hint: 'What worked, what could be clearer? (optional)',
          maxLines: 4,
          minLines: 3,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: feedback.hasRated ? 'Update feedback' : 'Submit feedback',
          height: 46,
          enabled: selected > 0,
          onPressed: () {
            ref
                .read(lessonFeedbackProvider(widget.lessonId).notifier)
                .rate(selected, comment: _controller.text.trim());
            setState(() => _pending = 0);
            FocusScope.of(context).unfocus();
            showDemoSnack(context, 'Thanks — your feedback reached Amit Sir');
          },
        ),
      ],
    );
  }
}
