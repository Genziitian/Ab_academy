import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class LiveClassroomScreen extends ConsumerWidget {
  const LiveClassroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(liveTabProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _LiveTopBar(),
              const _SlideStage(),
              const _LiveQuickActions(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E3EA),
                            borderRadius: AppRadius.pill,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider)),
                        ),
                        child: Row(
                          children: [
                            UnderlineTabs(
                              tabs: const ['Chat', 'Questions', 'Notes'],
                              selected: tab,
                              gap: 20,
                              onSelected: (value) =>
                                  ref.read(liveTabProvider.notifier).select(value),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: switch (tab) {
                          'Questions' => const _QuestionsPanel(),
                          'Notes' => const _NotesPanel(),
                          _ => const _ChatPanel(),
                        },
                      ),
                      const _ChatComposer(),
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

class _LiveTopBar extends StatelessWidget {
  const _LiveTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: const Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mathematics Live',
                    style: AppText.tabular(13.5, FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Amit Sir • ${MockData.upcomingLive.studentsEnrolled} watching',
                    style: AppText.tabular(
                      10.5,
                      FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const LivePill(
              label: 'LIVE',
              background: Color(0x2ED93A3A),
              textColor: Color(0xFFFF7A7A),
              dotColor: Color(0xFFFF5A5A),
            ),
          ],
        ),
      ),
    );
  }
}

/// The teacher's slide, with their camera thumbnail pinned bottom-right.
class _SlideStage extends StatelessWidget {
  const _SlideStage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF4F5F8), borderRadius: AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.liveSlideLabel,
                  style: AppText.eyebrow(color: const Color(0xFF8A90A0), size: 10),
                ),
                const SizedBox(height: 9),
                Text(MockData.liveSlideTitle, style: AppText.tabular(16, FontWeight.w700)),
                const SizedBox(height: 9),
                const Divider(height: 1, color: Color(0xFFE2E5EC)),
                const SizedBox(height: 9),
                for (final line in MockData.liveSlideBody) ...[
                  Text(
                    line,
                    style: AppText.tabular(
                      12.5,
                      FontWeight.w500,
                      color: AppColors.textBodyAlt,
                    ).copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 7),
                ],
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 78,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D42),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const InitialsAvatar(
                    initials: 'AS',
                    size: 30,
                    fontSize: 11,
                    background: AppColors.primary,
                    foreground: Colors.white,
                  ),
                  Positioned(
                    left: 6,
                    bottom: 5,
                    child: Text(
                      'Amit Sir',
                      style: AppText.tabular(
                        8.5,
                        FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveQuickActions extends StatelessWidget {
  const _LiveQuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          _QuickAction(
            icon: LucideIcons.hand,
            label: 'Raise Hand',
            onTap: () => showDemoSnack(context, 'Hand raised — your teacher has been notified'),
          ),
          const SizedBox(width: 8),
          _QuickAction(
            icon: LucideIcons.edit3,
            label: 'Notes',
            onTap: () => showDemoSnack(context, 'Open the Notes tab to jot points down'),
          ),
          const SizedBox(width: 8),
          _QuickAction(
            icon: LucideIcons.maximize,
            label: 'Full screen',
            onTap: () => showDemoSnack(context, 'Full screen coming soon'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppRadius.xs,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xs,
          child: SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(12, FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: MockData.liveChat.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _ChatBubble(message: MockData.liveChat[index]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final LiveMessage message;

  @override
  Widget build(BuildContext context) {
    final avatarPalette = switch (message.initials) {
      'RK' => (AppColors.primaryTint, AppColors.primary),
      'PS' => (AppColors.hindiTint, AppColors.hindi),
      'AK' => (AppColors.scienceTint, AppColors.scienceInk),
      _ => (AppColors.primary, Colors.white),
    };

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(
          initials: message.initials,
          size: 28,
          fontSize: 10,
          background: avatarPalette.$1,
          foreground: avatarPalette.$2,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(message.author, style: AppText.tabular(12, FontWeight.w700)),
                  if (message.isTeacher) ...[
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
                ],
              ),
              const SizedBox(height: 3),
              Text(
                message.body,
                style: AppText.tabular(
                  13,
                  message.isTeacher ? FontWeight.w500 : FontWeight.w400,
                  color: message.isTeacher ? const Color(0xFF2A2E45) : AppColors.textBodyAlt,
                ).copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );

    if (!message.isTeacher) return content;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FD),
        borderRadius: AppRadius.sm,
        border: Border.all(color: const Color(0xFFE3E5F6)),
      ),
      child: content,
    );
  }
}

class _QuestionsPanel extends StatelessWidget {
  const _QuestionsPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: MockData.liveQuestions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final question = MockData.liveQuestions[index];
        final answered = question.meta == 'Answered';
        return AppCard(
          borderRadius: AppRadius.sm,
          padding: const EdgeInsets.all(13),
          shadow: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.body,
                style: AppText.tabular(13, FontWeight.w600).copyWith(height: 1.4),
              ),
              const SizedBox(height: 5),
              Text(
                question.meta ?? '',
                style: AppText.metaSm.copyWith(
                  color: answered ? AppColors.scienceInk : AppColors.textSubtle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotesPanel extends StatelessWidget {
  const _NotesPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      children: [
        AppCard(
          borderRadius: AppRadius.sm,
          padding: const EdgeInsets.all(14),
          shadow: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MockData.liveNoteTitle, style: AppText.tabular(12.5, FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                MockData.liveNoteBody,
                style: AppText.tabular(
                  13,
                  FontWeight.w400,
                  color: AppColors.textBodyAlt,
                ).copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer();

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, safeBottom > 0 ? safeBottom : 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                color: AppColors.fillMutedAlt,
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                'Ask a question…',
                style: AppText.tabular(13, FontWeight.w400, color: AppColors.textSubtle),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.primary,
            borderRadius: AppRadius.sm,
            child: InkWell(
              onTap: () => showDemoSnack(context, 'Chat opens when the class is live'),
              borderRadius: AppRadius.sm,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(LucideIcons.send, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
