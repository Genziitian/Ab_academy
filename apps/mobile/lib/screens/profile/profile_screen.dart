import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final pushEnabled = ref.watch(pushEnabledProvider);
    final openTickets = ref.watch(openTicketCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                InitialsAvatar(
                  initials: student.initials,
                  size: 62,
                  fontSize: 20,
                  border: AppColors.primaryTintBorder,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName, style: AppText.h5),
                      const SizedBox(height: 5),
                      Text(
                        student.summary,
                        style: AppText.tabular(12.5, FontWeight.w500, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 5),
                      Text(student.phone, style: AppText.meta.copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => showDemoSnack(context, 'Profile editing coming soon'),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(LucideIcons.edit3, size: 18, color: AppColors.textSubtle),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _SettingsGroup(
              label: 'ACCOUNT',
              rows: [
                _SettingsRow(
                  title: 'Personal Information',
                  onTap: () => showDemoSnack(context, 'Personal information'),
                ),
                _SettingsRow(title: 'Class & Board', onTap: () => context.push(Routes.setupClass)),
                _SettingsRow(
                  title: 'My Purchases',
                  onTap: () => context.push(Routes.purchase('class-10-complete-batch')),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _SettingsGroup(
              label: 'LEARNING',
              rows: [
                _SettingsRow(title: 'My Downloads', onTap: () => context.push(Routes.downloads)),
                _SettingsRow(title: 'Study Materials', onTap: () => context.push(Routes.materials)),
                _SettingsRow(title: 'Calendar', onTap: () => context.push(Routes.calendar)),
                _SettingsRow(
                  title: 'Download Settings',
                  value: 'Wi-Fi only',
                  onTap: () => showDemoSnack(context, 'Download over Wi-Fi only'),
                ),
                _SettingsRow(
                  title: 'Video Quality',
                  value: '720p',
                  onTap: () => showDemoSnack(context, 'Default video quality: 720p'),
                ),
                _SettingsRow(
                  title: 'Notifications',
                  trailing: _Toggle(
                    value: pushEnabled,
                    onChanged: (_) => ref.read(pushEnabledProvider.notifier).toggle(),
                  ),
                  onTap: () => ref.read(pushEnabledProvider.notifier).toggle(),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _SettingsGroup(
              label: 'SECURITY',
              rows: [
                _SettingsRow(
                  title: 'My Devices',
                  value: '2 active',
                  onTap: () => showDemoSnack(context, '2 devices signed in'),
                ),
                _SettingsRow(
                  title: 'Change Mobile Number',
                  onTap: () => context.push(Routes.login),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _SettingsGroup(
              label: 'SUPPORT',
              rows: [
                _SettingsRow(
                  title: 'My Tickets',
                  value: openTickets > 0 ? '$openTickets open' : null,
                  onTap: () => context.push(Routes.tickets),
                ),
                _SettingsRow(title: 'Raise a Ticket', onTap: () => context.push(Routes.newTicket)),
                _SettingsRow(
                  title: 'Privacy Policy',
                  onTap: () => showDemoSnack(context, 'Privacy policy'),
                ),
                _SettingsRow(
                  title: 'Terms of Use',
                  onTap: () => showDemoSnack(context, 'Terms of use'),
                ),
              ],
            ),
            const SizedBox(height: 26),

            GestureDetector(
              onTap: () => _confirmLogout(context, ref),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.sm,
                  border: Border.all(color: const Color(0xFFF2D6D6), width: 1.5),
                ),
                child: Text(
                  'Log Out',
                  style: AppText.tabular(14, FontWeight.w700, color: const Color(0xFFC43B3B)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Akhand Bharat Academy v1.0.0 (build 1)',
                style: AppText.tabular(11, FontWeight.w400, color: AppColors.textFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Log out?', style: AppText.cardTitle),
        content: Text(
          'You will need your mobile number to sign back in.',
          style: AppText.tabular(
            12.5,
            FontWeight.w400,
            color: AppColors.textMuted,
          ).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppText.buttonSm.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Log Out',
              style: AppText.buttonSm.copyWith(color: const Color(0xFFC43B3B)),
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.rows});

  final String label;
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupLabel(label),
        const SizedBox(height: 9),
        AppCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.md,
          shadow: null,
          clip: true,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(height: 1, thickness: 1, color: AppColors.dividerFaint),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.value, this.trailing, this.onTap});

  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppText.tabular(14, FontWeight.w600))),
            if (trailing != null)
              trailing!
            else if (value != null)
              Text(value!, style: AppText.meta.copyWith(fontSize: 12.5))
            else
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.trackMuted,
          borderRadius: AppRadius.pill,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
