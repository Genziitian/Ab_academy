import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/community.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// One community per enrolled course — students are joined automatically, so
/// this list is simply their enrolments.
class CommunityListScreen extends ConsumerWidget {
  const CommunityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = ref.watch(communitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Community', style: AppText.h3),
                  const SizedBox(height: 6),
                  Text(
                    'You are in a group for every course you are enrolled in.',
                    style: AppText.metaSm.copyWith(fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: communities.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: EmptyState(
                        icon: LucideIcons.users,
                        title: 'No communities yet',
                        body: 'Enrol in a course and its group opens here automatically.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      itemCount: communities.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _CommunityCard(community: communities[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    final palette = SubjectPalette.fromName(community.subject);
    final latest = community.latest;
    final pinned = community.messages.where((m) => m.pinned).length;

    return AppCard(
      onTap: () => context.push(Routes.communityFeed(community.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: palette.tint, borderRadius: AppRadius.xs),
                child: Icon(LucideIcons.users, size: 20, color: palette.ink),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(community.name, style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Text('${community.memberCount} members', style: AppText.metaSm),
                  ],
                ),
              ),
              if (pinned > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: Text(
                    '$pinned notice${pinned > 1 ? 's' : ''}',
                    style: AppText.tabular(10.5, FontWeight.w700, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadius.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${latest.isMe ? 'You' : latest.author}: ${latest.body}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tabular(
                        12.5,
                        FontWeight.w500,
                        color: AppColors.textBodyAlt,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(latest.timeLabel, style: AppText.metaSm.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
