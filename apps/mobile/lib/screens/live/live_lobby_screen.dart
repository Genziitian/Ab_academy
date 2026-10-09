import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/mock/mock_data.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../../widgets/common.dart';

class LiveLobbyScreen extends StatefulWidget {
  const LiveLobbyScreen({super.key});

  @override
  State<LiveLobbyScreen> createState() => _LiveLobbyScreenState();
}

class _LiveLobbyScreenState extends State<LiveLobbyScreen> {
  late int _secondsLeft = MockData.upcomingLive.startsInSeconds;
  Timer? _timer;
  bool _reminderSet = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_secondsLeft <= 0) return timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const session = MockData.upcomingLive;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SquareIconButton(
                    icon: LucideIcons.chevronLeft,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    const LivePill(),
                    const SizedBox(height: 26),
                    Text(
                      session.subject,
                      style: AppText.tabular(
                        13,
                        FontWeight.w600,
                        color: AppColors.maths,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(session.title, style: AppText.h1),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const InitialsAvatar(
                          initials: 'AS',
                          size: 36,
                          fontSize: 12,
                          background: AppColors.mathsTint,
                          foreground: AppColors.maths,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.teacherName,
                              style: AppText.tabular(13.5, FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(session.scheduleLabel, style: AppText.metaSm),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadius.xl,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _secondsLeft > 0 ? 'STARTS IN' : 'STARTING NOW',
                            style: AppText.eyebrow(size: 12, letterSpacing: 0.6),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _secondsLeft > 0 ? _countdown : 'Live',
                            style: AppText.tabular(46, FontWeight.w800, letterSpacing: -1.6),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _secondsLeft > 0
                                ? "We'll notify you when the class starts."
                                : 'Your teacher is in the room.',
                            style: AppText.metaSm.copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 62,
                          height: 26,
                          child: Stack(
                            children: [
                              for (final (index, entry) in [
                                ('PS', AppColors.primaryTint, AppColors.primary),
                                ('RK', AppColors.scienceTint, AppColors.scienceInk),
                                ('AK', AppColors.hindiTint, AppColors.hindi),
                              ].indexed)
                                Positioned(
                                  left: index * 18.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: InitialsAvatar(
                                      initials: entry.$1,
                                      size: 22,
                                      fontSize: 9,
                                      background: entry.$2,
                                      foreground: entry.$3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '${session.studentsEnrolled} students enrolled',
                          style: AppText.tabular(12.5, FontWeight.w500, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Join Class',
                    onPressed: () => context.push(Routes.liveRoom),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: _reminderSet ? 'Reminder set' : 'Remind me',
                    icon: _reminderSet ? LucideIcons.checkCircle : LucideIcons.bell,
                    onPressed: () {
                      setState(() => _reminderSet = true);
                      showDemoSnack(context, "We'll remind you 5 minutes before the class");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
