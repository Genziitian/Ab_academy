import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/community.dart';
import '../../data/providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../lessons/lecture_screen.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key, required this.communityId});

  final String communityId;

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    ref.read(communitiesProvider.notifier).post(widget.communityId, body);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(communityByIdProvider(widget.communityId));
    final messages = community.ordered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: community.name, subtitle: '${community.memberCount} members'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                itemCount: messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _MessageTile(message: messages[index]),
              ),
            ),
            MessageComposer(controller: _controller, hint: 'Message your batch…', onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final CommunityMessage message;

  @override
  Widget build(BuildContext context) {
    // Pinned teacher posts read as announcements rather than chat.
    if (message.pinned) {
      return AppCard(
        color: AppColors.warningTint,
        borderColor: AppColors.warningBorder,
        shadow: null,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.pin, size: 13, color: AppColors.warningInk),
                const SizedBox(width: 7),
                Text('ANNOUNCEMENT', style: AppText.badge(color: AppColors.warningInk, size: 9.5)),
                const Spacer(),
                Text(message.timeLabel, style: AppText.metaSm.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              message.body,
              style: AppText.tabular(
                13,
                FontWeight.w500,
                color: AppColors.ink,
              ).copyWith(height: 1.5),
            ),
            const SizedBox(height: 7),
            Text(message.author, style: AppText.metaSm.copyWith(color: AppColors.warningText)),
          ],
        ),
      );
    }

    final avatar = message.isMe
        ? (AppColors.primary, Colors.white)
        : (AppColors.primaryTint, AppColors.primary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(
          initials: message.initials,
          size: 30,
          fontSize: 11,
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
                      message.isMe ? 'You' : message.author,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tabular(12.5, FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(message.timeLabel, style: AppText.metaSm.copyWith(fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.body,
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
    );
  }
}
