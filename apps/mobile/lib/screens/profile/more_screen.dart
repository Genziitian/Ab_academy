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
import '../info/info_screens.dart';
import '../info/policy_content.dart';
import 'delete_account_screen.dart';
import '../../l10n/strings.dart';
import '../../widgets/language_toggle.dart';

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
                                    ? tx.studentViewProfile
                                    : tx.codeViewProfile(student.studentCode!),
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
            const SizedBox(height: 20),
            // Language, first: students who open the app in the wrong
            // language should find the switch without reading anything.
            SoftCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  TintIcon(icon: LucideIcons.languages, color: AppColors.ink, size: 38),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.hindi ? 'भाषा · Language' : 'Language · भाषा', style: AppText.tabular(15, FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(tx.languageHint, style: AppText.meta),
                      ],
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GroupHeading(tx.groupGeneral),
            MenuList(
              rows: [
                MenuRow(
                  icon: LucideIcons.headphones,
                  color: AppColors.primary,
                  label: tx.support,
                  value: openTickets > 0 ? tx.openTickets(openTickets) : null,
                  onTap: () => context.push(Routes.tickets),
                ),
                MenuRow(
                  icon: LucideIcons.settings,
                  color: AppColors.primary,
                  label: tx.settings,
                  onTap: () => context.push(Routes.profile),
                ),
                MenuRow(
                  icon: LucideIcons.share2,
                  color: AppColors.primary,
                  label: tx.shareApp,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: Env.siteUrl));
                    showDemoSnack(
                      context,
                      tx.linkCopied,
                    );
                  },
                ),
                MenuRow(
                  icon: LucideIcons.downloadCloud,
                  color: AppColors.primary,
                  label: tx.checkUpdates,
                  value: version,
                  onTap: () => showDemoSnack(
                    context,
                    '${tx.latestVersion(version.isEmpty ? '' : ' ($version)')}.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            GroupHeading(tx.groupInformation),
            MenuList(
              rows: [
                MenuRow(
                  icon: LucideIcons.info,
                  color: AppColors.primary,
                  label: tx.aboutUs,
                  onTap: () => openAbout(context),
                ),
                MenuRow(
                  icon: LucideIcons.gavel,
                  color: AppColors.primary,
                  label: tx.termsConditions,
                  onTap: () => openPolicy(context, Policies.terms),
                ),
                MenuRow(
                  icon: LucideIcons.shieldCheck,
                  color: AppColors.primary,
                  label: tx.privacyPolicy,
                  onTap: () => openPolicy(context, Policies.privacy),
                ),
                MenuRow(
                  icon: LucideIcons.receipt,
                  color: AppColors.primary,
                  label: tx.refundPolicy,
                  onTap: () => openPolicy(context, Policies.refund),
                ),
                MenuRow(
                  icon: LucideIcons.fileX,
                  color: AppColors.primary,
                  label: tx.dataDeletion,
                  onTap: () => openDataDeletion(context),
                ),
                MenuRow(
                  icon: LucideIcons.mail,
                  color: AppColors.primary,
                  label: tx.contactUs,
                  onTap: () => openContact(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            GroupHeading(tx.groupAccount),
            MenuList(
              rows: [
                MenuRow(
                  icon: LucideIcons.userX,
                  color: AppColors.liveInk,
                  label: tx.deleteAccountOrData,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DeleteAccountScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Material(
              color: AppColors.liveTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: AppColors.dangerBorder),
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
                        color: AppColors.liveInk,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tx.signOut,
                          style: AppText.tabular(
                            17,
                            FontWeight.w600,
                            color: AppColors.liveInk,
                          ),
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: AppColors.liveInk,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Text(
                'AB Academy${version.isEmpty ? '' : ' · $version'}',
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
        title: Text(tx.signOutQ, style: AppText.cardTitle),
        content: Text(
          tx.signOutBody,
          style: AppText.meta.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tx.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              tx.signOut,
              style: TextStyle(color: AppColors.liveInk),
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
