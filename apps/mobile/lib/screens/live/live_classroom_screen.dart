import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

/// 14 · Live classroom — slide stage on dark, chat / questions / notes below.
class LiveClassroomScreen extends ConsumerStatefulWidget {
  const LiveClassroomScreen({super.key});

  @override
  ConsumerState<LiveClassroomScreen> createState() =>
      _LiveClassroomScreenState();
}

class _LiveClassroomScreenState extends ConsumerState<LiveClassroomScreen> {
  static const _startedSecondsAgo = 24 * 60 + 18;

  late final List<LiveMessage> _chat = [...MockData.liveChat];
  late final List<LiveMessage> _questions = [...MockData.liveQuestions];
  final List<(String, String)> _notes = [
    (
      MockData.liveNoteTitle.replaceFirst('My notes · ', ''),
      MockData.liveNoteBody,
    ),
  ];
  int _elapsed = _startedSecondsAgo;
  bool _handRaised = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _elapsed++),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _send(String tab, String body) {
    final student = ref.read(studentProvider);
    setState(() {
      switch (tab) {
        case 'Chat':
          _chat.add(
            LiveMessage(author: 'You', initials: student.initials, body: body),
          );
        case 'Questions':
          _questions.add(
            LiveMessage(
              author: 'You',
              initials: student.initials,
              body: body,
              meta: 'Asked by you • 0 upvotes',
            ),
          );
        default:
          final now = TimeOfDay.now().format(context);
          _notes.insert(0, (now, body));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(liveTabProvider);
    final timer =
        '${_elapsed ~/ 60}:${(_elapsed % 60).toString().padLeft(2, '0')}';
    const session = MockData.liveNow;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.classroom,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 16, 10),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        '← Leave',
                        style: AppText.tabular(
                          13,
                          FontWeight.w400,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.live.withValues(alpha: 0.18),
                        borderRadius: AppRadius.badge,
                      ),
                      child: Text(
                        '● LIVE · $timer',
                        style: AppText.badge(
                          color: AppColors.liveOnDark,
                          size: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${session.studentsEnrolled} watching',
                      style: AppText.tabular(
                        12,
                        FontWeight.w400,
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _SlideStage(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final label in [
                              'Chat',
                              'Questions',
                              'My notes',
                            ])
                              Expanded(
                                child: _PanelTab(
                                  label: label == 'Questions'
                                      ? 'Questions (${_questions.length})'
                                      : label,
                                  selected: tab == label,
                                  onTap: () => ref
                                      .read(liveTabProvider.notifier)
                                      .select(label),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: switch (tab) {
                          'Questions' => _MessageList(messages: _questions),
                          'My notes' => _NotesList(notes: _notes),
                          _ => _MessageList(messages: _chat),
                        },
                      ),
                      MessageComposer(
                        hint: switch (tab) {
                          'Questions' => 'Ask the teacher a question…',
                          'My notes' => 'Write a note for yourself…',
                          _ => 'Message the class…',
                        },
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        leading: Material(
                          color: _handRaised
                              ? const Color(0xFFFFC56B)
                              : AppColors.fillMuted,
                          borderRadius: AppRadius.sm,
                          child: InkWell(
                            onTap: () {
                              setState(() => _handRaised = !_handRaised);
                              showDemoSnack(
                                context,
                                _handRaised
                                    ? 'Hand raised — Amit Sir can see it.'
                                    : 'Hand lowered.',
                              );
                            },
                            borderRadius: AppRadius.sm,
                            child: SizedBox.square(
                              dimension: 42,
                              child: Center(
                                child: Text(
                                  '✋',
                                  semanticsLabel: _handRaised
                                      ? 'Lower hand'
                                      : 'Raise hand',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        onSend: (body) => _send(tab, body),
                      ),
                    ],
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

class _SlideStage extends StatelessWidget {
  const _SlideStage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.sm,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.liveSlideLabel,
                  style: AppText.eyebrow(size: 10, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                Text(
                  MockData.liveSlideTitle,
                  style: AppText.tabular(18, FontWeight.w700),
                ),
                const SizedBox(height: 14),
                for (final line in MockData.liveSlideBody)
                  Text(
                    line,
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                    ).copyWith(height: 1.8),
                  ),
              ],
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: Container(
                width: 80,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.tag,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/feature-live-class.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'Teacher camera',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelTab extends StatelessWidget {
  const _PanelTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppText.tabular(
            13,
            selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<LiveMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(
              initials: message.initials,
              size: 26,
              fontSize: 10,
              background: message.isTeacher
                  ? AppColors.primary
                  : AppColors.primaryTint,
              foreground: message.isTeacher ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.author,
                        style: AppText.tabular(12, FontWeight.w600),
                      ),
                      if (message.isTeacher) ...[
                        const SizedBox(width: 6),
                        const StatusBadge.teacher(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    message.body,
                    style: AppText.tabular(
                      13,
                      FontWeight.w400,
                      color: AppColors.textBody,
                    ),
                  ),
                  if (message.meta != null)
                    Text(
                      message.meta!.replaceAll('•', '·'),
                      style: AppText.metaSm,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes});

  final List<(String, String)> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My note · ${notes[index].$1}',
              style: AppText.tabular(
                11,
                FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes[index].$2,
              style: AppText.tabular(
                13,
                FontWeight.w400,
                color: AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
