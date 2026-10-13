import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/env.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/feature_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import '../../widgets/web_page_screen.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version}';
  } catch (_) {
    return '';
  }
});

/// More tab — profile card, general tools, the academy's policies, sign out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final openTickets = ref.watch(openTicketCountProvider);
    final version = ref.watch(_versionProvider).value ?? '';

    void web(String title, String path) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WebPageScreen(title: title, path: path),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          children: [
            // Profile card.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => context.push(Routes.profile),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                    child: Row(
                      children: [
                        GradientAvatar(
                          initials: student.fullName,
                          size: 64,
                          ring: true,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.tabular(
                                  20,
                                  FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.studentCode == null
                                    ? 'STUDENT · View Profile'
                                    : '${student.studentCode} · View Profile',
                                style: AppText.tabular(
                                  14,
                                  FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const GroupHeading('General'),
            MenuList(
              rows: [
                MenuRow(
                  icon: LucideIcons.download,
                  color: AppColors.success,
                  label: 'Downloads',
                  onTap: () => context.push(Routes.downloads),
                ),
                MenuRow(
                  icon: LucideIcons.headphones,
                  color: const Color(0xFF0EA5E9),
                  label: 'Support',
                  value: openTickets > 0 ? '$openTickets open' : null,
                  onTap: () => context.push(Routes.tickets),
                ),
                MenuRow(
                  icon: LucideIcons.settings,
                  color: AppColors.primary,
                  label: 'Settings',
                  onTap: () => context.push(Routes.profile),
                ),
                MenuRow(
                  icon: LucideIcons.share2,
                  color: AppColors.english,
                  label: 'Share App',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: Env.siteUrl));
                    showDemoSnack(
                      context,
                      'Link copied — share it with friends.',
                    );
                  },
                ),
                MenuRow(
                  icon: LucideIcons.downloadCloud,
                  color: AppColors.teal,
                  label: 'Check for Updates',
                  value: version,
                  onTap: () => showDemoSnack(
                    context,
                    'You are on the latest version${version.isEmpty ? '' : ' ($version)'}.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const GroupHeading('Information'),
            MenuList(
              rows: [
                MenuRow(
                  icon: LucideIcons.info,
                  color: AppColors.violet,
                  label: 'About Us',
                  onTap: () => web('About Us', '/about'),
                ),
                MenuRow(
                  icon: LucideIcons.gavel,
                  color: AppColors.primary,
                  label: 'Terms & Conditions',
                  onTap: () => web('Terms & Conditions', '/terms'),
                ),
                MenuRow(
                  icon: LucideIcons.shieldCheck,
                  color: AppColors.success,
                  label: 'Privacy Policy',
                  onTap: () => web('Privacy Policy', '/privacy'),
                ),
                MenuRow(
                  icon: LucideIcons.mail,
                  color: const Color(0xFFF59E0B),
                  label: 'Contact Us',
                  onTap: () => web('Contact Us', '/contact'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Material(
              color: const Color(0xFFFDECEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFFF5B5BE)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _signOut(context, ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const TintIcon(
                        icon: LucideIcons.logOut,
                        color: Color(0xFFE11D48),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Sign out',
                          style: AppText.tabular(
                            17,
                            FontWeight.w600,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Color(0xFFE11D48),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Text(
                'Akhand Bharat Academy${version.isEmpty ? '' : ' · $version'}',
                style: AppText.meta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sign out?', style: AppText.cardTitle),
        content: Text(
          'You will need your mobile number or Google account to sign back in.',
          style: AppText.meta.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: Color(0xFFE11D48)),
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
