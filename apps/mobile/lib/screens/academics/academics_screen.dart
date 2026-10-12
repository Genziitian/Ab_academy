import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../calendar/calendar_screen.dart';
import '../live/live_sessions_screen.dart';
import '../materials/study_materials_screen.dart';

const _tabs = ['Live', 'Calendar', 'Notes'];

/// Academics tab — live sessions, the calendar and notes in one place.
/// `?tab=live|calendar|notes` opens a specific section.
class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> {
  late String _tab = _tabFor(widget.initialTab) ?? _tabs.first;

  static String? _tabFor(String? query) {
    if (query == null) return null;
    for (final tab in _tabs) {
      if (tab.toLowerCase() == query.toLowerCase()) return tab;
    }
    return null;
  }

  @override
  void didUpdateWidget(AcademicsScreen old) {
    super.didUpdateWidget(old);
    // Navigating to /academics?tab=… while the tab is already open.
    final next = _tabFor(widget.initialTab);
    if (widget.initialTab != old.initialTab && next != null) {
      setState(() => _tab = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academics', style: AppText.h2),
                  const SizedBox(height: 14),
                  SegmentedTabs(
                    tabs: _tabs,
                    selected: _tab,
                    onSelected: (tab) => setState(() => _tab = tab),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (_tab) {
                'Calendar' => const CalendarView(),
                'Notes' => const NotesView(),
                _ => const LiveSessionsView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
