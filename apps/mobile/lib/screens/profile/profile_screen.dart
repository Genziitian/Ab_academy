import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

const _qualities = ['Auto', '360p', '480p', '720p'];

/// 19 · Profile — account, learning and support settings.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _quality = '720p';

  Future<void> _pickQuality() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Text(
                'Lower quality saves mobile data and avoids buffering.',
                style: AppText.meta,
              ),
            ),
            for (final q in _qualities)
              ListTile(
                title: Text(q, style: AppText.rowTitle),
                trailing: q == _quality
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(q),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _quality = picked);
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final pushEnabled = ref.watch(pushEnabledProvider);
    final openTickets = ref.watch(openTicketCountProvider);
    final purchases = ref.watch(coursesProvider).length;

    final summary = [
      'Class ${student.classLevel}',
      if (student.stream != null) student.stream!,
      '${student.medium} medium',
    ].join(' · ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                InitialsAvatar(
                  initials: student.initials,
                  size: 60,
                  fontSize: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: AppText.tabular(18, FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        style: AppText.tabular(
                          13,
                          FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        student.phone,
                        style: AppText.tabular(
                          12,
                          FontWeight.w400,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.setupClass),
                  child: Text(
                    'Edit',
                    style: AppText.tabular(
                      13,
                      FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              label: 'ACCOUNT',
              rows: [
                _Row(
                  title: 'Personal information',
                  onTap: () => showDemoSnack(
                    context,
                    'Name and phone are set at sign-in.',
                  ),
                ),
                _Row(
                  title: 'Class & stream',
                  value:
                      '${student.classLevel}${student.stream == null ? '' : ' · ${student.stream}'}',
                  onTap: () => context.push(Routes.setupClass),
                ),
                _Row(
                  title: 'My purchases',
                  value: '$purchases',
                  onTap: () => context.go(Routes.courses),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              label: 'LEARNING',
              rows: [
                _Row(
                  title: 'Downloads',
                  value: MockData.downloadsUsedLabel.replaceAll(' used', ''),
                  onTap: () => context.push(Routes.downloads),
                ),
                _Row(
                  title: 'Calendar',
                  onTap: () => context.push(Routes.calendar),
                ),
                _Row(
                  title: 'Video quality',
                  value: _quality,
                  onTap: _pickQuality,
                ),
                _Row(
                  title: 'Notifications',
                  trailing: Switch.adaptive(
                    value: pushEnabled,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) =>
                        ref.read(pushEnabledProvider.notifier).toggle(),
                  ),
                  onTap: () => ref.read(pushEnabledProvider.notifier).toggle(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              label: 'SUPPORT',
              rows: [
                _Row(
                  title: 'My tickets',
                  value: openTickets == 0 ? '' : '$openTickets open',
                  onTap: () => context.push(Routes.tickets),
                ),
                _Row(
                  title: 'Privacy & terms',
                  onTap: () => showDemoSnack(
                    context,
                    'Read them at akhandbharatacademy.in/privacy',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.sm,
                side: BorderSide(color: AppColors.dangerBorder, width: 1.5),
              ),
              child: InkWell(
                onTap: () => _confirmLogout(context),
                borderRadius: AppRadius.sm,
                child: SizedBox(
                  height: 46,
                  child: Center(
                    child: Text(
                      'Log out',
                      style: AppText.tabular(
                        14,
                        FontWeight.w600,
                        color: AppColors.liveInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Log out?', style: AppText.cardTitle),
        content: Text(
          'You will need your mobile number or Google account to sign back in.',
          style: AppText.tabular(
            13,
            FontWeight.w400,
            color: AppColors.textMuted,
          ).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppText.buttonSm.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Log out',
              style: AppText.buttonSm.copyWith(color: AppColors.liveInk),
            ),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false) || !context.mounted) return;
    await ref.read(sessionProvider.notifier).signOut();
    if (!context.mounted) return;
    context.go(Routes.login);
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.rows});

  final String label;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow(letterSpacing: 0.9)),
        const SizedBox(height: 6),
        ListCard(children: rows),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.onTap,
    this.value = '',
    this.trailing,
  });

  final String title;
  final String value;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: trailing == null ? 12 : 4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: AppText.tabular(14, FontWeight.w500)),
            ),
            if (trailing != null)
              trailing!
            else ...[
              if (value.isNotEmpty)
                Text(
                  value,
                  style: AppText.tabular(
                    12,
                    FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '›',
                style: AppText.tabular(
                  16,
                  FontWeight.w400,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
