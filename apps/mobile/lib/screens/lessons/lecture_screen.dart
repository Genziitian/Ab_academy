import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/lesson_extras.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'lecture_player.dart';

/// The lecture: player on top, then About / Discussion / Notes / Feedback.
class LectureScreen extends ConsumerStatefulWidget {
  const LectureScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends ConsumerState<LectureScreen> {
  static const _tabs = ['About', 'Discussion', 'Notes', 'Feedback'];

  String _tab = 'About';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            LecturePlayer(title: 'Quadratic Equations · 03', onBack: () => context.pop()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: UnderlineTabs(
                tabs: _tabs,
                selected: _tab,
                gap: 20,
                onSelected: (value) => setState(() => _tab = value),
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
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('MATHEMATICS', style: AppText.eyebrow(color: AppColors.maths)),
        const SizedBox(height: 10),
        Text('Quadratic Equations — Class 03', style: AppText.h4),
        const SizedBox(height: 10),
        Row(
          children: [
            const InitialsAvatar(
              initials: 'AS',
              size: 28,
              fontSize: 10.5,
              background: AppColors.mathsTint,
              foreground: AppColors.maths,
            ),
            const SizedBox(width: 9),
            Text('Amit Sir', style: AppText.label),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _LectureAction(
              icon: LucideIcons.download,
              label: 'Download',
              onTap: () => showDemoSnack(context, 'Saved for offline use'),
            ),
            const SizedBox(width: 9),
            _LectureAction(
              icon: LucideIcons.bookmark,
              label: 'Save',
              onTap: () => showDemoSnack(context, 'Added to your saved lessons'),
            ),
            const SizedBox(width: 9),
            _LectureAction(
              icon: LucideIcons.checkCircle,
              label: 'Complete',
              iconColor: AppColors.science,
              onTap: () => showDemoSnack(context, 'Lesson marked complete'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('About this lesson', style: AppText.cardTitle),
        const SizedBox(height: 8),
        Text(
          'Solving quadratic equations by factorisation and by completing the square, with the '
          'standard form ax² + bx + c = 0. Includes four board-pattern examples from the 2023 '
          'and 2024 papers.',
          style: AppText.body,
        ),
        const SizedBox(height: 22),
        Text('Next lesson', style: AppText.cardTitle),
        const SizedBox(height: 10),
        AppCard(
          borderRadius: AppRadius.md,
          padding: const EdgeInsets.all(14),
          shadow: null,
          onTap: () => context.push(Routes.liveLobby),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.mathsTint,
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.maths),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class 04 · Practice Session',
                      style: AppText.tabular(13.5, FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Live today • 6:00 PM',
                      style: AppText.tabular(11.5, FontWeight.w400, color: AppColors.live),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscussionTab extends ConsumerStatefulWidget {
  const _DiscussionTab({required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<_DiscussionTab> createState() => _DiscussionTabState();
}

class _DiscussionTabState extends ConsumerState<_DiscussionTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    ref.read(lessonCommentsProvider(widget.lessonId).notifier).post(body);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(lessonCommentsProvider(widget.lessonId));

    return Column(
      children: [
        Expanded(
          child: comments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: EmptyState(
                    icon: LucideIcons.messageSquare,
                    title: 'No questions yet',
                    body: 'Ask the first question about this lesson.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (context, index) => _CommentTile(comment: comments[index]),
                ),
        ),
        _Composer(
          controller: _controller,
          hint: 'Ask a question about this lesson…',
          onSend: _post,
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, this.isReply = false});

  final LessonComment comment;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final avatar = comment.isTeacher
        ? (AppColors.primary, Colors.white)
        : (AppColors.primaryTint, AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(
              initials: comment.initials,
              size: isReply ? 26 : 30,
              fontSize: isReply ? 9.5 : 11,
              background: avatar.$1,
              foreground: avatar.$2,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.isMe ? 'You' : comment.author,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.tabular(12.5, FontWeight.w700),
                        ),
                      ),
                      if (comment.isTeacher) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Text(
                            'TEACHER',
                            style: AppText.badge(
                              color: Colors.white,
                              size: 8.5,
                            ).copyWith(letterSpacing: 0.6),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(comment.timeLabel, style: AppText.metaSm.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.body,
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                      color: AppColors.textBodyAlt,
                    ).copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 14),
            child: Column(
              children: [
                for (final reply in comment.replies)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CommentTile(comment: reply, isReply: true),
                  ),
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
        Text('Open them here — no download needed.', style: AppText.metaSm),
        const SizedBox(height: 14),
        for (final attachment in attachments) ...[
          AppCard(
            borderRadius: AppRadius.md,
            padding: const EdgeInsets.all(14),
            shadow: null,
            onTap: () => context.push(Routes.pdf(attachment.id)),
            child: Row(
              children: [
                IconTile(
                  background: AppColors.pdfTint,
                  label: 'PDF',
                  labelStyle: AppText.badge(
                    color: const Color(0xFFC43B3B),
                    size: 9.5,
                  ).copyWith(letterSpacing: 0),
                  size: 40,
                  radius: 11,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attachment.title, style: AppText.tabular(13.5, FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(attachment.sizeLabel, style: AppText.metaSm),
                    ],
                  ),
                ),
                Text('Open', style: AppText.tabular(12, FontWeight.w700, color: AppColors.primary)),
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
        AppCard(
          shadow: null,
          child: Row(
            children: [
              Text(
                feedback.averageRating.toStringAsFixed(1),
                style: AppText.tabular(30, FontWeight.w800, letterSpacing: -1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Stars(rating: feedback.averageRating.round(), size: 16),
                    const SizedBox(height: 5),
                    Text('${feedback.ratingCount} ratings', style: AppText.metaSm),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(feedback.hasRated ? 'Your rating' : 'Rate this lesson', style: AppText.cardTitle),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var star = 1; star <= 5; star++)
              GestureDetector(
                onTap: () => setState(() => _pending = star),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    star <= selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 34,
                    color: star <= selected ? const Color(0xFFE0A33A) : AppColors.textDisabled,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _controller,
          hint: 'What worked, what could be clearer? (optional)',
          maxLines: 4,
          minLines: 3,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: feedback.hasRated ? 'Update feedback' : 'Submit feedback',
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
        if (feedback.myComment != null && feedback.myComment!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('You wrote', style: AppText.cardTitleSm),
          const SizedBox(height: 6),
          Text(feedback.myComment!, style: AppText.body),
        ],
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 14});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: star <= rating ? const Color(0xFFE0A33A) : AppColors.textDisabled,
          ),
      ],
    );
  }
}

/// Text field + send button, shared by the lecture discussion and community feed.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.hint, required this.onSend});

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, safeBottom > 0 ? safeBottom : 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppTextField(controller: controller, hint: hint, maxLines: 4, minLines: 1),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.primary,
            borderRadius: AppRadius.sm,
            child: InkWell(
              onTap: onSend,
              borderRadius: AppRadius.sm,
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(LucideIcons.send, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LectureAction extends StatelessWidget {
  const _LectureAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: AppRadius.sm,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(height: 6),
                Text(label, style: AppText.tabular(11, FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exposed so the community feed can reuse the same composer.
class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) =>
      _Composer(controller: controller, hint: hint, onSend: onSend);
}
