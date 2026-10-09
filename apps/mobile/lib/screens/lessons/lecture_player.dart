import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';

/// Player chrome for a recorded lecture. Playback itself is not wired yet —
/// the controls drive local state so the screen behaves, and the real player
/// drops in behind this same surface.
class LecturePlayer extends StatefulWidget {
  const LecturePlayer({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  State<LecturePlayer> createState() => _LecturePlayerState();
}

class _LecturePlayerState extends State<LecturePlayer> {
  bool _playing = true;
  double _progress = 0.73;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.tabular(
                          13,
                          FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDemoSnack(context, 'Playback options coming soon'),
                      icon: const Icon(LucideIcons.moreVertical, size: 20, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: const Color(0xFF1E2024))),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () =>
                              setState(() => _progress = (_progress - 0.05).clamp(0.0, 1.0)),
                          icon: const Icon(LucideIcons.rotateCcw, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => setState(() => _playing = !_playing),
                          child: Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 28,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () =>
                              setState(() => _progress = (_progress + 0.05).clamp(0.0, 1.0)),
                          icon: const Icon(LucideIcons.rotateCw, size: 24, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withValues(alpha: 0.12),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.5),
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (value) => setState(() => _progress = value),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_stamp(_progress * 3120)} / 52:00',
                                style: AppText.tabular(
                                  11,
                                  FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              Row(
                                children: [
                                  _PlayerChip(
                                    label: '1.25×',
                                    onTap: () => showDemoSnack(context, 'Playback speed'),
                                  ),
                                  const SizedBox(width: 12),
                                  _PlayerChip(
                                    label: '720p',
                                    onTap: () => showDemoSnack(context, 'Video quality'),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => showDemoSnack(context, 'Full screen coming soon'),
                                    child: const Icon(
                                      LucideIcons.maximize,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stamp(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppText.tabular(10.5, FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
