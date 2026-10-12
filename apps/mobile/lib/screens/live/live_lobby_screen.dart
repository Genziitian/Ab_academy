import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// 13 · Live lobby — countdown to the next class, with a reminder.
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

  @override
  Widget build(BuildContext context) {
    const session = MockData.upcomingLive;
    final started = _secondsLeft <= 0;
    final chapter = (session.chapterLabel ?? '')
        .split(' · ')
        .first
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      InitialsAvatar(
                        initials: session.teacherInitials,
                        size: 72,
                        fontSize: 22,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${session.subject.toUpperCase()}${chapter.isEmpty ? '' : ' · $chapter'}',
                        style: AppText.eyebrow(
                          color: AppColors.primary,
                          size: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(session.title, style: AppText.h3),
                      const SizedBox(height: 4),
                      Text(
                        '${session.teacherName} · ${session.scheduleLabel.replaceAll(' •', '')}',
                        style: AppText.tabular(
                          14,
                          FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        started ? 'Class has started' : 'Class starts in',
                        style: AppText.label,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CountdownBox(
                            value: _secondsLeft ~/ 60,
                            label: 'MIN',
                          ),
                          const SizedBox(width: 10),
                          _CountdownBox(value: _secondsLeft % 60, label: 'SEC'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.card,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Before class', style: AppText.rowTitle),
                            const SizedBox(height: 6),
                            for (final line in [
                              'Revise the ${session.chapterLabel?.split(' · ').first ?? 'chapter'} formula sheet',
                              'Keep a notebook ready for practice questions',
                              '${session.studentsEnrolled} students enrolled',
                            ])
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '✓ $line',
                                  style: AppText.tabular(
                                    13,
                                    FontWeight.w400,
                                    color: AppColors.textBody,
                                  ).copyWith(height: 1.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  children: [
                    if (started)
                      PrimaryButton(
                        label: 'Join Live Class',
                        onPressed: () =>
                            context.pushReplacement(Routes.liveRoom),
                      )
                    else
                      PrimaryButton(
                        label: _reminderSet ? '✓ Reminder set' : 'Remind me',
                        onPressed: () {
                          setState(() => _reminderSet = !_reminderSet);
                          if (_reminderSet) {
                            showDemoSnack(
                              context,
                              "We'll notify you 5 minutes before class.",
                            );
                          }
                        },
                      ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Add to calendar',
                      onPressed: () => context.push(Routes.calendar),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: AppText.mono(34, weight: FontWeight.w400),
          ),
          Text(
            label,
            style: AppText.tabular(
              11,
              FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
