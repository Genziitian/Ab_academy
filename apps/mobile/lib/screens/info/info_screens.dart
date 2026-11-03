import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/academy.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/academy_mark.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import '../profile/delete_account_screen.dart';
import 'policy_content.dart';

/// About, Contact and the policies, drawn natively in the app's Saffron & Ink
/// style instead of loading the website.

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

void openPolicy(BuildContext context, PolicyDoc doc, {Widget? footer}) =>
    _push(context, PolicyScreen(doc: doc, footer: footer));

void openDataDeletion(BuildContext context) => openPolicy(
  context,
  Policies.dataDeletion,
  footer: Builder(
    builder: (context) => PrimaryButton(
      label: 'Request deletion',
      onPressed: () => _push(context, const DeleteAccountScreen()),
    ),
  ),
);

void openAbout(BuildContext context) => _push(context, const AboutScreen());

void openContact(BuildContext context) => _push(context, const ContactScreen());

/// Shared page frame: top bar, padded scrolling column.
class _InfoFrame extends StatelessWidget {
  const _InfoFrame({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        children: children,
      ),
    );
  }
}

/// Clay eyebrow, serif headline and intro — the top of every info page.
class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title, this.intro});

  final String eyebrow;
  final String title;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppText.eyebrow(color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        Text(title, style: AppText.serif(38, height: 1.0)),
        if (intro != null) ...[
          const SizedBox(height: 14),
          Text(intro!, style: AppText.bodyLg.copyWith(height: 1.6)),
        ],
      ],
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.doc, this.footer});

  final PolicyDoc doc;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _InfoFrame(
      title: doc.title,
      children: [
        _Header(
          eyebrow: 'Updated ${Academy.policiesUpdated}',
          title: doc.title,
          intro: doc.intro,
        ),
        if (footer != null) ...[const SizedBox(height: 20), footer!],
        const SizedBox(height: 12),
        for (final (i, section) in doc.sections.indexed)
          _SectionBlock(number: i + 1, section: section),
        const SizedBox(height: 28),
        const _ContactCard(),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.number, required this.section});

  final int number;
  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number.toString().padLeft(2, '0'),
            style: AppText.eyebrow(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(section.heading, style: AppText.sectionTitle),
          for (final block in section.blocks) ...[
            const SizedBox(height: 10),
            switch (block) {
              Para(:final text) => Text(text, style: AppText.body),
              Bullets(:final items) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 9, right: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(child: Text(item, style: AppText.body)),
                        ],
                      ),
                    ),
                ],
              ),
            },
          ],
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoFrame(
      title: 'About us',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
          decoration: const BoxDecoration(
            color: AppColors.primaryDeep,
            borderRadius: AppRadius.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AcademyMark(size: 64),
              const SizedBox(height: 18),
              Text(
                'ABOUT ${Academy.name.toUpperCase()}',
                style: AppText.eyebrow(color: AppColors.textOnDarkAccent),
              ),
              const SizedBox(height: 10),
              Text(
                'Built in Bihar, for Bihar Board.',
                style: AppText.serif(
                  36,
                  height: 1.0,
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'A teacher with ${Academy.teacherYears} years in the classroom '
                'and a developer, building the crash course they wish students '
                'had: affordable, focused and in your language.',
                style: AppText.bodyLg.copyWith(
                  color: AppColors.textOnDark,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const _Header(eyebrow: 'The people behind it', title: 'Founders'),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, f) in Academy.founders.indexed) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(
                child: _FounderCard(name: f.name, role: f.role),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        const _Header(
          eyebrow: 'What we do',
          title: 'One teacher. Three subjects.',
        ),
        const SizedBox(height: 16),
        const _Fact(
          icon: LucideIcons.bookOpen,
          title: 'Class 12 PCM crash courses',
          body:
              'Physics, Chemistry and Maths for the Bihar Board exam, chapter by chapter.',
        ),
        const _Fact(
          icon: LucideIcons.playCircle,
          title: 'Recorded classes, live doubts',
          body:
              '${Academy.teacher} records every class and takes every live doubt session himself.',
        ),
        const _Fact(
          icon: LucideIcons.indianRupee,
          title: 'Priced for every student',
          body: '₹249 a subject, with a free demo class to try first.',
        ),
        const SizedBox(height: 20),
        const _ContactCard(),
      ],
    );
  }
}

class _FounderCard extends StatelessWidget {
  const _FounderCard({required this.name, required this.role});

  final String name;
  final String role;

  String get _initials => name
      .replaceAll(RegExp(r"\b(Sir|Ma'am)\b"), '')
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? '' : w[0])
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceMuted, AppColors.fillMutedAlt],
              ),
            ),
            child: Text(
              _initials,
              style: AppText.serif(72, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: AppText.serif(26, height: 1.0)),
        const SizedBox(height: 6),
        Text(
          role.toUpperCase(),
          style: AppText.eyebrow(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TintIcon(icon: icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.cardTitleLg),
                  const SizedBox(height: 4),
                  Text(body, style: AppText.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoFrame(
      title: 'Contact us',
      children: [
        const _Header(
          eyebrow: 'We reply within 2 working days',
          title: 'Talk to us.',
          intro:
              'For questions about a course, a payment or your account, raise a '
              'support ticket — it reaches the team fastest and you can follow '
              'the reply in the app.',
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Raise a support ticket',
          onPressed: () => context.push(Routes.newTicket),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'My tickets',
          onPressed: () => context.push(Routes.tickets),
        ),
        const SizedBox(height: 28),
        const _ContactCard(),
      ],
    );
  }
}

/// Email (tap to copy) and postal address.
class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ContactRow(
            icon: LucideIcons.mail,
            label: 'Email',
            value: Academy.email,
            trailing: LucideIcons.copy,
            onTap: () {
              Clipboard.setData(const ClipboardData(text: Academy.email));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Email address copied.')),
                );
            },
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          _ContactRow(
            icon: LucideIcons.mapPin,
            label: 'Address',
            value: '${Academy.name}\n${Academy.address.join('\n')}',
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TintIcon(icon: icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppText.eyebrow()),
                  const SizedBox(height: 4),
                  Text(value, style: AppText.cardTitle.copyWith(height: 1.45)),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(trailing, size: 18, color: AppColors.textSubtle),
              ),
          ],
        ),
      ),
    );
  }
}
