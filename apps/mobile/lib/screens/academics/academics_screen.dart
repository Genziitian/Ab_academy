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

/// Academics tab — one tile per part of the learning journey.
class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        LucideIcons.calendarDays,
        'Calendar',
        AppGradients.violet,
        () => context.push(Routes.calendar),
      ),
      (
        LucideIcons.video,
        'Live Sessions',
        AppGradients.orange,
        () => context.push(Routes.live),
      ),
      (
        LucideIcons.fileText,
        'Class Notes',
        AppGradients.green,
        () => context.push(Routes.notes),
      ),
      (
        LucideIcons.headphones,
        'Support',
        AppGradients.sky,
        () => context.push(Routes.tickets),
      ),
      (
        LucideIcons.download,
        'Downloads',
        AppGradients.violet,
        () => context.push(Routes.downloads),
      ),
      (
        LucideIcons.bell,
        'Announcements',
        AppGradients.blue,
        () => context.go(Routes.updates),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          children: [
            const PageTitle(
              title: 'Academics',
              subtitle: 'Everything for your learning journey',
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
        'Calendar',
        'Classes and tests by day',
        const CalendarView(),
      ),
      'notes' => (
        'Class Notes',
        'Chapter PDFs from your courses',
        const NotesView(),
      ),
      _ => (
        'Live Sessions',
        'Join live or catch the recording',
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
