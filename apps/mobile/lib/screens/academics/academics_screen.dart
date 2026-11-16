import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ui_kit.dart';
import '../calendar/calendar_screen.dart';
import '../live/live_sessions_screen.dart';
import '../materials/study_materials_screen.dart';
import '../../l10n/strings.dart';

/// Academics tab — one tile per part of the learning journey.
class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        LucideIcons.video,
        tx.liveSessions,
        AppGradients.orange,
        () => context.push(Routes.live),
      ),
      (
        LucideIcons.fileText,
        tx.classNotesTitle,
        AppGradients.green,
        () => context.push(Routes.notes),
      ),
      (
        LucideIcons.headphones,
        tx.support,
        AppGradients.sky,
        () => context.push(Routes.tickets),
      ),
      (
        LucideIcons.bell,
        tx.announcements,
        AppGradients.blue,
        () => context.push(Routes.notifications),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          children: [
            PageTitle(
              title: tx.academics,
              subtitle: tx.academicsLead,
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                for (final (icon, label, gradient, onTap) in tiles)
                  SoftCard(
                    onTap: onTap,
                    radius: 26,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientIcon(
                          icon: icon,
                          gradient: gradient,
                          size: 70,
                          iconSize: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppText.tabular(17, FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One Academics section as its own page: /academics/live, /academics/notes,
/// /academics/calendar.
class AcademicsSectionScreen extends StatelessWidget {
  const AcademicsSectionScreen({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, Widget body) = switch (section) {
      'calendar' => (
        tx.calendar,
        tx.calendarLead,
        const CalendarView(),
      ),
      'notes' => (
        tx.classNotesTitle,
        tx.classNotesLead,
        const NotesView(),
      ),
      _ => (
        tx.liveSessions,
        tx.liveSessionsLead,
        const LiveSessionsView(),
      ),
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  const BackSquareButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.h2),
                        Text(subtitle, style: AppText.meta),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
